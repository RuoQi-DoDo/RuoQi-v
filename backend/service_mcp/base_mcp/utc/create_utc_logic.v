module utc

import log
import time
import rand
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseUtc }

// ═══ Tool ═══
pub fn create_utc_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_utc_create'
		title:        'Create UTC time zone'
		description:  'Create a new base UTC time zone band.'
		input_schema: '{"type":"object","required":["name","lngRangeStart","lngRangeEnd","lngMid"],"properties":{"sort":{"type":"integer"},"name":{"type":"string"},"lngRangeStart":{"type":"number"},"lngRangeEnd":{"type":"number"},"lngMid":{"type":"number"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: false
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[CreateUtcReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := create_utc_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn create_utc_usecase(pool &dbpool.DatabasePoolable, req CreateUtcReq) !CreateUtcResp {
	create_utc_domain(req)!
	return create_utc_repo(pool, req)
}

// ═══ Domain ═══
fn create_utc_domain(req CreateUtcReq) ! {
	if req.name == '' {
		return error('name is required')
	}
}

// ═══ DTO ═══
pub struct CreateUtcReq {
	sort            ?int   @[json: 'sort']
	name            string @[json: 'name']
	lng_range_start f64    @[json: 'lngRangeStart']
	lng_range_end   f64    @[json: 'lngRangeEnd']
	lng_mid         f64    @[json: 'lngMid']
}

pub struct CreateUtcResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_utc_repo(pool &dbpool.DatabasePoolable, req CreateUtcReq) !CreateUtcResp {
	time_now := time.now()
	new_id := rand.uuid_v7()
	base_utc := BaseUtc{
		id:              new_id
		sort:            req.sort
		name:            req.name
		lng_range_start: req.lng_range_start
		lng_range_end:   req.lng_range_end
		lng_mid:         req.lng_mid
		created_at:      time_now
		updated_at:      time_now
	}

	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_utc into BaseUtc
	} or { return error('Failed to create UTC: ${err}') }

	return CreateUtcResp{
		id:  new_id
		msg: 'Utc created successfully'
	}
}
