module currency

import log
import time
import rand
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseCurrency }

// ═══ Tool ═══
pub fn create_currency_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_currency_create'
		title:        'Create currency'
		description:  'Create a new base currency record.'
		input_schema: '{"type":"object","required":["englishName","simplifiedName","currencyCode","currencySymbol","decimalPlace","exchangeRate","exchangeRateFluctuation","exchangeRateUsed","status"],"properties":{"englishName":{"type":"string"},"simplifiedName":{"type":"string"},"currencyCode":{"type":"string"},"currencySymbol":{"type":"string"},"decimalPlace":{"type":"integer","minimum":0},"exchangeRate":{"type":"number"},"exchangeRateFluctuation":{"type":"number"},"exchangeRateUsed":{"type":"number"},"sort":{"type":"integer"},"status":{"type":"integer"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: false
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[CreateCurrencyReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := create_currency_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn create_currency_usecase(pool &dbpool.DatabasePoolable, req CreateCurrencyReq) !CreateCurrencyResp {
	create_currency_domain(req)!
	return create_currency_repo(pool, req)
}

// ═══ Domain ═══
fn create_currency_domain(req CreateCurrencyReq) ! {
	if req.currency_code == '' {
		return error('currency_code is required')
	}
	if req.english_name == '' && req.simplified_name == '' {
		return error('english_name or simplified_name is required')
	}
}

// ═══ DTO ═══
pub struct CreateCurrencyReq {
	english_name              string @[json: 'englishName']
	simplified_name           string @[json: 'simplifiedName']
	currency_code             string @[json: 'currencyCode']
	currency_symbol           string @[json: 'currencySymbol']
	decimal_place             u8     @[json: 'decimalPlace']
	exchange_rate             f64    @[json: 'exchangeRate']
	exchange_rate_fluctuation f64    @[json: 'exchangeRateFluctuation']
	exchange_rate_used        f64    @[json: 'exchangeRateUsed']
	sort                      ?int   @[json: 'sort']
	status                    u8     @[json: 'status']
}

pub struct CreateCurrencyResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_currency_repo(pool &dbpool.DatabasePoolable, req CreateCurrencyReq) !CreateCurrencyResp {
	time_now := time.now()
	new_id := rand.uuid_v7()
	base_currency := BaseCurrency{
		id:                        new_id
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

	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_currency into BaseCurrency
	} or { return error('Failed to create Currency: ${err}') }

	return CreateCurrencyResp{
		id:  new_id
		msg: 'Currency created successfully'
	}
}
