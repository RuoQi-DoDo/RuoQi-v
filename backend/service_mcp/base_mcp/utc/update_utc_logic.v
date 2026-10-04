module utc

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseUtc }

// ═══ Tool ═══
pub fn update_utc_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_utc_update'
		title:        'Update UTC time zone'
		description:  'Update an existing base UTC time zone band by id.'
		input_schema: '{"type":"object","required":["id"],"properties":{"id":{"type":"string"},"sort":{"type":"integer"},"name":{"type":"string"},"lngRangeStart":{"type":"number"},"lngRangeEnd":{"type":"number"},"lngMid":{"type":"number"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[UpdateUtcReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := update_utc_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn update_utc_usecase(pool &dbpool.DatabasePoolable, req UpdateUtcReq) !UpdateUtcResp {
	update_utc_domain(req)!
	return update_utc_repo(pool, req)
}

// ═══ Domain ═══
fn update_utc_domain(req UpdateUtcReq) ! {
	if req.id == '' {
		return error('utc id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateUtcReq {
	id              string  @[json: 'id']
	sort            ?int    @[json: 'sort']
	name            ?string @[json: 'name']
	lng_range_start ?f64    @[json: 'lngRangeStart']
	lng_range_end   ?f64    @[json: 'lngRangeEnd']
	lng_mid         ?f64    @[json: 'lngMid']
}

pub struct UpdateUtcResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_utc_repo(pool &dbpool.DatabasePoolable, req UpdateUtcReq) !UpdateUtcResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// vfmt off
	up_expr := {
		if v := req.sort {
			sort == v
		},
		if v := req.name {
			name == v
		},
		if v := req.lng_range_start {
			lng_range_start == v
		},
		if v := req.lng_range_end {
			lng_range_end == v
		},
		if v := req.lng_mid {
			lng_mid == v
		},
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseUtc set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateUtcResp{
		msg: 'UTC updated successfully'
	}
}
