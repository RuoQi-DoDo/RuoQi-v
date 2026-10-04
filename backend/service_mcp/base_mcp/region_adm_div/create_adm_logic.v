module region_adm_div

import log
import time
import rand
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseRegionAdmDiv }

// ═══ Tool ═══
pub fn create_adm_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_adm_div_create'
		title:        'Create administrative division'
		description:  'Create a new country/region administrative division record.'
		input_schema: '{"type":"object","required":["parentId","regionId","sysAdmCode","sysAdmName","level","treeId","status"],"properties":{"parentId":{"type":"string"},"regionId":{"type":"string"},"sysAdmCode":{"type":"string"},"sysAdmName":{"type":"string"},"nameLocal":{"type":"string"},"govtCode":{"type":"string"},"gidZero":{"type":"string"},"hasc":{"type":"string"},"isoTwo":{"type":"string"},"isoThree":{"type":"string"},"numeric":{"type":"string"},"postalCode":{"type":"string"},"level":{"type":"integer","minimum":1,"maximum":5},"treeId":{"type":"string"},"coordBounds":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"admMergerName":{"type":"string"},"admShortName":{"type":"string"},"pinyin":{"type":"string"},"first":{"type":"string"},"nameEn":{"type":"string"},"nameZh":{"type":"string"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: false
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[CreateAdmReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := create_adm_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn create_adm_usecase(pool &dbpool.DatabasePoolable, req CreateAdmReq) !CreateAdmResp {
	create_adm_domain(req)!
	return create_adm_repo(pool, req)
}

// ═══ Domain ═══
fn create_adm_domain(req CreateAdmReq) ! {
	if req.region_id == '' {
		return error('region_id is required')
	}
	if req.sys_adm_code == '' {
		return error('sys_adm_code is required')
	}
	if req.sys_adm_name == '' {
		return error('sys_adm_name is required')
	}
}

// ═══ DTO ═══
pub struct CreateAdmReq {
	parent_id       string  @[json: 'parentId']
	region_id       string  @[json: 'regionId']
	sys_adm_code    string  @[json: 'sysAdmCode']
	sys_adm_name    string  @[json: 'sysAdmName']
	name_local      ?string @[json: 'nameLocal']
	govt_code       ?string @[json: 'govtCode']
	gid_zero        ?string @[json: 'gidZero']
	hasc            ?string @[json: 'hasc']
	iso_two         ?string @[json: 'isoTwo']
	iso_three       ?string @[json: 'isoThree']
	numeric         ?string @[json: 'numeric']
	postal_code     ?string @[json: 'postalCode']
	level           u8      @[json: 'level']
	tree_id         string  @[json: 'treeId']
	coord_bounds    ?string @[json: 'coordBounds']
	sort            ?u64    @[json: 'sort']
	status          u8      @[json: 'status']
	adm_merger_name ?string @[json: 'admMergerName']
	adm_short_name  ?string @[json: 'admShortName']
	pinyin          ?string @[json: 'pinyin']
	first           string  @[json: 'first']
	name_en         ?string @[json: 'nameEn']
	name_zh         ?string @[json: 'nameZh']
}

pub struct CreateAdmResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_adm_repo(pool &dbpool.DatabasePoolable, req CreateAdmReq) !CreateAdmResp {
	time_now := time.now()
	new_id := rand.uuid_v7()
	level := if req.level == 0 { u8(1) } else { req.level }
	first := if req.first == '' { '0' } else { req.first }
	base_adm := BaseRegionAdmDiv{
		id:              new_id
		parent_id:       req.parent_id
		region_id:       req.region_id
		sys_adm_code:    req.sys_adm_code
		sys_adm_name:    req.sys_adm_name
		name_local:      req.name_local
		govt_code:       req.govt_code
		gid_zero:        req.gid_zero
		hasc:            req.hasc
		iso_two:         req.iso_two
		iso_three:       req.iso_three
		numeric:         req.numeric
		postal_code:     req.postal_code
		level:           level
		tree_id:         req.tree_id
		coord_bounds:    req.coord_bounds
		sort:            req.sort
		status:          req.status
		adm_merger_name: req.adm_merger_name
		adm_short_name:  req.adm_short_name
		pinyin:          req.pinyin
		first:           first
		name_en:         req.name_en
		name_zh:         req.name_zh
		created_at:      time_now
		updated_at:      time_now
	}

	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_adm into BaseRegionAdmDiv
	} or { return error('Failed to create Adm: ${err}') }

	return CreateAdmResp{
		id:  new_id
		msg: 'Adm created successfully'
	}
}
