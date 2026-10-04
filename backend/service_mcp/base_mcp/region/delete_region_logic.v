module region

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseRegion }

// ═══ Tool ═══
pub fn delete_region_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_delete'
		title:        'Delete regions'
		description:  'Soft-delete base countries/regions by id list (sets del_flag = -1).'
		input_schema: '{"type":"object","required":["ids"],"properties":{"ids":{"type":"array","items":{"type":"string"},"minItems":1}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:   false
			destructive_hint: true
			idempotent_hint:  true
			open_world_hint:  false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[DeleteRegionReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := delete_region_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn delete_region_usecase(pool &dbpool.DatabasePoolable, req DeleteRegionReq) !DeleteRegionResp {
	delete_region_domain(req)!
	return delete_region_repo(pool, req.region_ids)
}

// ═══ Domain ═══
fn delete_region_domain(req DeleteRegionReq) ! {
	if req.region_ids.len == 0 {
		return error('No Region ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteRegionReq {
	region_ids []string @[json: 'ids']
}

pub struct DeleteRegionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_region_repo(pool &dbpool.DatabasePoolable, region_ids []string) !DeleteRegionResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update BaseRegion set del_flag = -1, updated_at = time.now()
		where id in region_ids && del_flag == 0
	} or { return error('Failed to soft-delete region: ${err}') }

	return DeleteRegionResp{
		msg: '${region_ids} region(s) deleted successfully'
	}
}
