module region

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseRegion }

// ═══ Tool ═══
pub fn update_region_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_update'
		title:        'Update region'
		description:  'Update an existing base country/region record by id.'
		input_schema: '{"type":"object","required":["id"],"properties":{"id":{"type":"string"},"sysRegionCode":{"type":"string"},"sysRegionName":{"type":"string"},"nameLocal":{"type":"string"},"langcodeLocal":{"type":"string"},"govtCode":{"type":"string"},"gidZero":{"type":"string"},"hasc":{"type":"string"},"isoTwo":{"type":"string"},"isoThree":{"type":"string"},"numeric":{"type":"string"},"internationalPrefix":{"type":"string"},"phoneAreaCode":{"type":"string"},"postalCode":{"type":"string"},"domainName":{"type":"string"},"continentCode":{"type":"string"},"coordBounds":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"nameEn":{"type":"string"},"nameZh":{"type":"string"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[UpdateRegionReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := update_region_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn update_region_usecase(pool &dbpool.DatabasePoolable, req UpdateRegionReq) !UpdateRegionResp {
	update_region_domain(req)!
	return update_region_repo(pool, req)
}

// ═══ Domain ═══
fn update_region_domain(req UpdateRegionReq) ! {
	if req.id == '' {
		return error('region id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateRegionReq {
	id                   string  @[json: 'id']
	sys_region_code      ?string @[json: 'sysRegionCode']
	sys_region_name      ?string @[json: 'sysRegionName']
	name_local           ?string @[json: 'nameLocal']
	langcode_local       ?string @[json: 'langcodeLocal']
	govt_code            ?string @[json: 'govtCode']
	gid_zero             ?string @[json: 'gidZero']
	hasc                 ?string @[json: 'hasc']
	iso_two              ?string @[json: 'isoTwo']
	iso_three            ?string @[json: 'isoThree']
	numeric              ?string @[json: 'numeric']
	international_prefix ?string @[json: 'internationalPrefix']
	phone_area_code      ?string @[json: 'phoneAreaCode']
	postal_code          ?string @[json: 'postalCode']
	domain_name          ?string @[json: 'domainName']
	continent_code       ?string @[json: 'continentCode']
	coord_bounds         ?string @[json: 'coordBounds']
	sort                 ?int    @[json: 'sort']
	status               ?u8     @[json: 'status']
	name_en              ?string @[json: 'nameEn']
	name_zh              ?string @[json: 'nameZh']
}

pub struct UpdateRegionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_region_repo(pool &dbpool.DatabasePoolable, req UpdateRegionReq) !UpdateRegionResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// vfmt off
	up_expr := {
		if v := req.sys_region_code {
			sys_region_code == v
		},
		if v := req.sys_region_name {
			sys_region_name == v
		},
		if v := req.name_local {
			name_local == v
		},
		if v := req.langcode_local {
			langcode_local == v
		},
		if v := req.govt_code {
			govt_code == v
		},
		if v := req.gid_zero {
			gid_zero == v
		},
		if v := req.hasc {
			hasc == v
		},
		if v := req.iso_two {
			iso_two == v
		},
		if v := req.iso_three {
			iso_three == v
		},
		if v := req.numeric {
			numeric == v
		},
		if v := req.international_prefix {
			international_prefix == v
		},
		if v := req.phone_area_code {
			phone_area_code == v
		},
		if v := req.postal_code {
			postal_code == v
		},
		if v := req.domain_name {
			domain_name == v
		},
		if v := req.continent_code {
			continent_code == v
		},
		if v := req.coord_bounds {
			coord_bounds == v
		},
		if v := req.sort {
			sort == v
		},
		if v := req.status {
			status == v
		},
		if v := req.name_en {
			name_en == v
		},
		if v := req.name_zh {
			name_zh == v
		},
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseRegion set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateRegionResp{
		msg: 'Region updated successfully'
	}
}
