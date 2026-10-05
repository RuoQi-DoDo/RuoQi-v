module language

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseLanguage }

// ═══ Tool ═══
pub fn delete_language_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_language_delete'
		title:        'Delete languages'
		description:  'Soft-delete base languages by id list (sets del_flag = -1).'
		input_schema: '{"type":"object","required":["ids"],"properties":{"ids":{"type":"array","items":{"type":"string"},"minItems":1}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:   false
			destructive_hint: true
			idempotent_hint:  true
			open_world_hint:  false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[DeleteLanguageReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := delete_language_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn delete_language_usecase(pool &dbpool.DatabasePoolable, req DeleteLanguageReq) !DeleteLanguageResp {
	delete_language_domain(req)!
	return delete_language_repo(pool, req.language_ids)
}

// ═══ Domain ═══
fn delete_language_domain(req DeleteLanguageReq) ! {
	if req.language_ids.len == 0 {
		return error('No Language ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteLanguageReq {
	language_ids []string @[json: 'ids']
}

pub struct DeleteLanguageResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_language_repo(pool &dbpool.DatabasePoolable, language_ids []string) !DeleteLanguageResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update BaseLanguage set del_flag = -1, updated_at = time.now()
		where id in language_ids && del_flag == 0
	} or { return error('Failed to soft-delete language: ${err}') }

	return DeleteLanguageResp{
		msg: '${language_ids} language(s) deleted successfully'
	}
}
