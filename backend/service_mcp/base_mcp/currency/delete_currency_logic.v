module currency

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseCurrency }

// ═══ Tool ═══
pub fn delete_currency_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_currency_delete'
		title:        'Delete currencies'
		description:  'Soft-delete base currencies by id list (sets del_flag = -1).'
		input_schema: '{"type":"object","required":["ids"],"properties":{"ids":{"type":"array","items":{"type":"string"},"minItems":1}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:   false
			destructive_hint: true
			idempotent_hint:  true
			open_world_hint:  false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[DeleteCurrencyReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := delete_currency_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn delete_currency_usecase(pool &dbpool.DatabasePoolable, req DeleteCurrencyReq) !DeleteCurrencyResp {
	delete_currency_domain(req)!
	return delete_currency_repo(pool, req.currency_ids)
}

// ═══ Domain ═══
fn delete_currency_domain(req DeleteCurrencyReq) ! {
	if req.currency_ids.len == 0 {
		return error('No Currency ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteCurrencyReq {
	currency_ids []string @[json: 'ids']
}

pub struct DeleteCurrencyResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_currency_repo(pool &dbpool.DatabasePoolable, currency_ids []string) !DeleteCurrencyResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update BaseCurrency set del_flag = -1, updated_at = time.now()
		where id in currency_ids && del_flag == 0
	} or { return error('Failed to soft-delete currency: ${err}') }

	return DeleteCurrencyResp{
		msg: '${currency_ids} currency(ies) deleted successfully'
	}
}
