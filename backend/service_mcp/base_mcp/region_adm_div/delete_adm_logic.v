module region_adm_div

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseRegionAdmDiv }

// ═══ Tool ═══
pub fn delete_adm_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_adm_div_delete'
		title:        'Delete administrative divisions'
		description:  'Soft-delete country/region administrative divisions by id list (sets del_flag = -1).'
		input_schema: '{"type":"object","required":["ids"],"properties":{"ids":{"type":"array","items":{"type":"string"},"minItems":1}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:   false
			destructive_hint: true
			idempotent_hint:  true
			open_world_hint:  false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[DeleteAdmReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := delete_adm_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn delete_adm_usecase(pool &dbpool.DatabasePoolable, req DeleteAdmReq) !DeleteAdmResp {
	delete_adm_domain(req)!
	return delete_adm_repo(pool, req.adm_ids)
}

// ═══ Domain ═══
fn delete_adm_domain(req DeleteAdmReq) ! {
	if req.adm_ids.len == 0 {
		return error('No Adm ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteAdmReq {
	adm_ids []string @[json: 'ids']
}

pub struct DeleteAdmResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_adm_repo(pool &dbpool.DatabasePoolable, adm_ids []string) !DeleteAdmResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update BaseRegionAdmDiv set del_flag = -1, updated_at = time.now()
		where id in adm_ids && del_flag == 0
	} or { return error('Failed to soft-delete adm: ${err}') }

	return DeleteAdmResp{
		msg: '${adm_ids} adm(s) deleted successfully'
	}
}
