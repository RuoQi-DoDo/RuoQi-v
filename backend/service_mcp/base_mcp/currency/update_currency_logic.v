module currency

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseCurrency }

// ═══ Tool ═══
pub fn update_currency_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_currency_update'
		title:        'Update currency'
		description:  'Update an existing base currency record by id.'
		input_schema: '{"type":"object","required":["id"],"properties":{"id":{"type":"string"},"englishName":{"type":"string"},"simplifiedName":{"type":"string"},"currencyCode":{"type":"string"},"currencySymbol":{"type":"string"},"decimalPlace":{"type":"integer","minimum":0},"exchangeRate":{"type":"number"},"exchangeRateFluctuation":{"type":"number"},"exchangeRateUsed":{"type":"number"},"sort":{"type":"integer"},"status":{"type":"integer"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[UpdateCurrencyReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := update_currency_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn update_currency_usecase(pool &dbpool.DatabasePoolable, req UpdateCurrencyReq) !UpdateCurrencyResp {
	update_currency_domain(req)!
	return update_currency_repo(pool, req)
}

// ═══ Domain ═══
fn update_currency_domain(req UpdateCurrencyReq) ! {
	if req.id == '' {
		return error('currency id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateCurrencyReq {
	id                        string  @[json: 'id']
	english_name              ?string @[json: 'englishName']
	simplified_name           ?string @[json: 'simplifiedName']
	currency_code             ?string @[json: 'currencyCode']
	currency_symbol           ?string @[json: 'currencySymbol']
	decimal_place             ?u8     @[json: 'decimalPlace']
	exchange_rate             ?f64    @[json: 'exchangeRate']
	exchange_rate_fluctuation ?f64    @[json: 'exchangeRateFluctuation']
	exchange_rate_used        ?f64    @[json: 'exchangeRateUsed']
	sort                      ?int    @[json: 'sort']
	status                    ?u8     @[json: 'status']
}

pub struct UpdateCurrencyResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_currency_repo(pool &dbpool.DatabasePoolable, req UpdateCurrencyReq) !UpdateCurrencyResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

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
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseCurrency set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateCurrencyResp{
		msg: 'Currency updated successfully'
	}
}
