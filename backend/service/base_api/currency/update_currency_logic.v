module currency

import dto
import veb
import log
import time
import json2 as json
import model.schema_base { BaseCurrency }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Currency) update_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_currency_usecase(mut ctx Context, req UpdateCurrencyReq) !dto.MsgResp {
	// Domain 校验
	update_currency_domain(&req)!

	// Repository 更新
	return update_currency_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_currency_domain(req &UpdateCurrencyReq) ! {
	if req.id == '' {
		return error('currency id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateCurrencyReq {
	id                        string  @[json: 'id'; description: '唯一标识']
	english_name              ?string @[json: 'englishName'; description: '英文名称']
	simplified_name           ?string @[json: 'simplifiedName'; description: '简体中文名称']
	currency_code             ?string @[json: 'currencyCode'; description: 'ISO 货币代码']
	currency_symbol           ?string @[json: 'currencySymbol'; description: '货币符号']
	decimal_place             ?u8     @[json: 'decimalPlace'; description: '金额小数位数']
	exchange_rate             ?f64    @[json: 'exchangeRate'; description: '汇率']
	exchange_rate_fluctuation ?f64    @[json: 'exchangeRateFluctuation'; description: '汇率波动值']
	exchange_rate_used        ?f64    @[json: 'exchangeRateUsed'; description: '实际使用的汇率']
	sort                      ?int    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status                    ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_currency_repo(mut ctx Context, req UpdateCurrencyReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.english_name {
			english_name == v
		},
		if v := req.simplified_name {
			simplified_name == v
		},
		if v := req.currency_code {
			currency_code == v
		},
		if v := req.currency_symbol {
			currency_symbol == v
		},
		if v := req.decimal_place {
			decimal_place == v
		},
		if v := req.exchange_rate {
			exchange_rate == v
		},
		if v := req.exchange_rate_fluctuation {
			exchange_rate_fluctuation == v
		},
		if v := req.exchange_rate_used {
			exchange_rate_used == v
		},
		if v := req.sort {
			sort == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseCurrency set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'Currency updated successfully'
	}
}
