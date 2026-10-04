module utc

import log
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseUtc }

// ═══ Tool ═══
pub fn find_utc_all_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_utc_find_all'
		title:        'List UTC time zones'
		description:  'List all base UTC time zone bands ordered by sort.'
		input_schema: '{"type":"object","properties":{}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  true
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, _ string) !mcp.ToolResult {
		result := find_utc_all_usecase(pool) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn find_utc_all_usecase(pool &dbpool.DatabasePoolable) !UtcListResp {
	find_utc_all_domain()
	return find_utc_all_repo(pool)
}

// ═══ Domain ═══
fn find_utc_all_domain() {
}

// ═══ DTO ═══
pub struct UtcListReq {}

pub struct UtcData {
	id              string @[json: 'id']
	sort            ?int   @[json: 'sort']
	name            string @[json: 'name']
	lng_range_start f64    @[json: 'lngRangeStart']
	lng_range_end   f64    @[json: 'lngRangeEnd']
	lng_mid         f64    @[json: 'lngMid']
}

pub struct UtcListResp {
	total int
	data  []UtcData
}

// ═══ Repository ═══
fn find_utc_all_repo(pool &dbpool.DatabasePoolable) !UtcListResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	result := sql db {
		select from BaseUtc order by sort
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []UtcData{}
	for row in result {
		datalist << UtcData{
			id:              row.id
			sort:            row.sort
			name:            row.name
			lng_range_start: row.lng_range_start
			lng_range_end:   row.lng_range_end
			lng_mid:         row.lng_mid
		}
	}

	return UtcListResp{
		total: datalist.len
		data:  datalist
	}
}
