module currency

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_base { BaseCurrency }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Currency) create_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_currency_usecase(mut ctx Context, req CreateCurrencyReq) !dto.MsgResp {
	create_currency_domain(&req)!
	return create_currency_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_currency_domain(req &CreateCurrencyReq) ! {
	if req.currency_code == '' {
		return error('currency_code is required')
	}
	if req.english_name == '' && req.simplified_name == '' {
		return error('english_name or simplified_name is required')
	}
}

// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ═══ DTO ═══
pub struct CreateCurrencyReq {
	english_name              string @[json: 'englishName'; description: '货币英文名称']
	simplified_name           string @[json: 'simplifiedName'; description: '货币简体中文名称']
	currency_code             string @[json: 'currencyCode'; description: 'ISO 货币代码，例如 CNY']
	currency_symbol           string @[json: 'currencySymbol'; description: '货币符号，例如 ¥']
	decimal_place             u8     @[json: 'decimalPlace'; description: '货币金额保留的小数位数']
	exchange_rate             f64    @[json: 'exchangeRate'; description: '汇率']
	exchange_rate_fluctuation f64    @[json: 'exchangeRateFluctuation'; description: '汇率波动值']
	exchange_rate_used        f64    @[json: 'exchangeRateUsed'; description: '实际使用的汇率']
	sort                      ?int   @[json: 'sort'; description: '排序值，数字越小越靠前']
	status                    u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn create_currency_repo(mut ctx Context, req CreateCurrencyReq) !dto.MsgResp {
	time_now := time.now()
	base_currency := BaseCurrency{
		id:                        rand.uuid_v7()
		english_name:              req.english_name
		simplified_name:           req.simplified_name
		currency_code:             req.currency_code
		currency_symbol:           req.currency_symbol
		decimal_place:             req.decimal_place
		exchange_rate:             req.exchange_rate
		exchange_rate_fluctuation: req.exchange_rate_fluctuation
		exchange_rate_used:        req.exchange_rate_used
		sort:                      req.sort
		status:                    req.status
		created_at:                time_now
		updated_at:                time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_currency into BaseCurrency
	} or { return error('Failed to create Currency: ${err}') }

	return dto.MsgResp{
		msg: 'Currency created successfully'
	}
}
