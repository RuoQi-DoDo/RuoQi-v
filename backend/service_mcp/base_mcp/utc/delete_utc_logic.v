module utc

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseUtc }

// ═══ Tool ═══
pub fn delete_utc_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_utc_delete'
		title:        'Delete UTC time zones'
		description:  'Soft-delete base UTC time zone bands by id list (sets del_flag = -1).'
		input_schema: '{"type":"object","required":["ids"],"properties":{"ids":{"type":"array","items":{"type":"string"},"minItems":1}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:   false
			destructive_hint: true
			idempotent_hint:  true
			open_world_hint:  false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[DeleteUtcReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := delete_utc_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn delete_utc_usecase(pool &dbpool.DatabasePoolable, req DeleteUtcReq) !DeleteUtcResp {
	delete_utc_domain(req)!
	return delete_utc_repo(pool, req.utc_ids)
}

// ═══ Domain ═══
fn delete_utc_domain(req DeleteUtcReq) ! {
	if req.utc_ids.len == 0 {
		return error('No Utc ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteUtcReq {
	utc_ids []string @[json: 'ids']
}

pub struct DeleteUtcResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_utc_repo(pool &dbpool.DatabasePoolable, utc_ids []string) !DeleteUtcResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update BaseUtc set del_flag = -1, updated_at = time.now()
		where id in utc_ids && del_flag == 0
	} or { return error('Failed to soft-delete utc: ${err}') }

	return DeleteUtcResp{
		msg: '${utc_ids} utc(s) deleted successfully'
	}
}
