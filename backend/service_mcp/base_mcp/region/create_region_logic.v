module region

import log
import time
import rand
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseRegion }

// ═══ Tool ═══
pub fn create_region_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_create'
		title:        'Create region'
		description:  'Create a new base country/region record.'
		input_schema: '{"type":"object","required":["sysRegionCode","sysRegionName","langcodeLocal","status"],"properties":{"sysRegionCode":{"type":"string"},"sysRegionName":{"type":"string"},"nameLocal":{"type":"string"},"langcodeLocal":{"type":"string"},"govtCode":{"type":"string"},"gidZero":{"type":"string"},"hasc":{"type":"string"},"isoTwo":{"type":"string"},"isoThree":{"type":"string"},"numeric":{"type":"string"},"internationalPrefix":{"type":"string"},"phoneAreaCode":{"type":"string"},"postalCode":{"type":"string"},"domainName":{"type":"string"},"continentCode":{"type":"string"},"coordBounds":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"nameEn":{"type":"string"},"nameZh":{"type":"string"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: false
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[CreateRegionReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := create_region_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn create_region_usecase(pool &dbpool.DatabasePoolable, req CreateRegionReq) !CreateRegionResp {
	create_region_domain(req)!
	return create_region_repo(pool, req)
}

// ═══ Domain ═══
fn create_region_domain(req CreateRegionReq) ! {
	if req.sys_region_code == '' {
		return error('sys_region_code is required')
	}
	if req.sys_region_name == '' {
		return error('sys_region_name is required')
	}
}

// ═══ DTO ═══
pub struct CreateRegionReq {
	sys_region_code      string  @[json: 'sysRegionCode']
	sys_region_name      string  @[json: 'sysRegionName']
	name_local           string  @[json: 'nameLocal']
	langcode_local       string  @[json: 'langcodeLocal']
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
	status               u8      @[json: 'status']
	name_en              ?string @[json: 'nameEn']
	name_zh              ?string @[json: 'nameZh']
}

pub struct CreateRegionResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_region_repo(pool &dbpool.DatabasePoolable, req CreateRegionReq) !CreateRegionResp {
	time_now := time.now()
	new_id := rand.uuid_v7()
	base_region := BaseRegion{
		id:                   new_id
		sys_region_code:      req.sys_region_code
		sys_region_name:      req.sys_region_name
		name_local:           req.name_local
		langcode_local:       req.langcode_local
		govt_code:            req.govt_code
		gid_zero:             req.gid_zero
		hasc:                 req.hasc
		iso_two:              req.iso_two
		iso_three:            req.iso_three
		numeric:              req.numeric
		international_prefix: req.international_prefix
		phone_area_code:      req.phone_area_code
		postal_code:          req.postal_code
		domain_name:          req.domain_name
		continent_code:       req.continent_code
		coord_bounds:         req.coord_bounds
		sort:                 req.sort
		status:               req.status
		name_en:              req.name_en
		name_zh:              req.name_zh
		created_at:           time_now
		updated_at:           time_now
	}

	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_region into BaseRegion
	} or { return error('Failed to create Region: ${err}') }

	return CreateRegionResp{
		id:  new_id
		msg: 'Region created successfully'
	}
}
