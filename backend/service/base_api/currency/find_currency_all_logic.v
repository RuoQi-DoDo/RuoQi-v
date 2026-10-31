module currency

import veb
import log
import time
import model.schema_base { BaseCurrency }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Currency) find_currency_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CurrencyListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_currency_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_currency_all_usecase(mut ctx Context, req CurrencyListReq) !CurrencyListResp {
	find_currency_all_domain()
	return find_currency_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_currency_all_domain() {
}

// ═══ DTO ═══
pub struct CurrencyListReq {
	page          int    @[json: 'page'; description: '页码，从 1 开始']
	page_size     int    @[json: 'pageSize'; description: '每页记录数']
	english_name  string @[json: 'englishName'; description: '英文名称']
	currency_code string @[json: 'currencyCode'; description: 'ISO 货币代码']
	status        []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct CurrencyData {
	id                        string  @[json: 'id'; description: '唯一标识']
	english_name              string  @[json: 'englishName'; description: '货币英文名称']
	simplified_name           string  @[json: 'simplifiedName'; description: '货币简体中文名称']
	currency_code             string  @[json: 'currencyCode'; description: 'ISO 货币代码']
	currency_symbol           string  @[json: 'currencySymbol'; description: '货币符号']
	decimal_place             u8      @[json: 'decimalPlace'; description: '金额小数位数']
	exchange_rate             f64     @[json: 'exchangeRate'; description: '汇率']
	exchange_rate_fluctuation f64     @[json: 'exchangeRateFluctuation'; description: '汇率波动值']
	exchange_rate_used        f64     @[json: 'exchangeRateUsed'; description: '实际使用的汇率']
	sort                      ?int    @[json: 'sort'; description: '排序值']
	status                    u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	updater_id                ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id                ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at                string  @[json: 'createdAt'; description: '创建时间']
	updated_at                string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at                string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct CurrencyListResp {
	total int            @[description: '总记录数']
	data  []CurrencyData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_currency_all_repo(mut ctx Context, req CurrencyListReq) !CurrencyListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseCurrency
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
			if req.english_name != '' {english_name == req.english_name},
			if req.currency_code != '' {currency_code == req.currency_code},
			if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from BaseCurrency where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []CurrencyData{}
	for row in result {
		datalist << CurrencyData{
			id:                        row.id
			english_name:              row.english_name
			simplified_name:           row.simplified_name
			currency_code:             row.currency_code
			currency_symbol:           row.currency_symbol
			decimal_place:             row.decimal_place
			exchange_rate:             row.exchange_rate
			exchange_rate_fluctuation: row.exchange_rate_fluctuation
			exchange_rate_used:        row.exchange_rate_used
			sort:                      row.sort
			status:                    row.status
			creator_id:                row.creator_id
			updater_id:                row.updater_id
			created_at:                row.created_at.format_ss()
			updated_at:                row.updated_at.format_ss()
			deleted_at:                (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return CurrencyListResp{
		total: count
		data:  datalist
	}
}
