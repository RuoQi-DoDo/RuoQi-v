module region_adm_div

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseRegionAdmDiv }

// ═══ Tool ═══
pub fn update_adm_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_adm_div_update'
		title:        'Update administrative division'
		description:  'Update an existing country/region administrative division record by id.'
		input_schema: '{"type":"object","required":["id"],"properties":{"id":{"type":"string"},"parentId":{"type":"string"},"regionId":{"type":"string"},"sysAdmCode":{"type":"string"},"sysAdmName":{"type":"string"},"nameLocal":{"type":"string"},"govtCode":{"type":"string"},"gidZero":{"type":"string"},"hasc":{"type":"string"},"isoTwo":{"type":"string"},"isoThree":{"type":"string"},"numeric":{"type":"string"},"postalCode":{"type":"string"},"level":{"type":"integer","minimum":1,"maximum":5},"treeId":{"type":"string"},"coordBounds":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"admMergerName":{"type":"string"},"admShortName":{"type":"string"},"pinyin":{"type":"string"},"first":{"type":"string"},"nameEn":{"type":"string"},"nameZh":{"type":"string"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[UpdateAdmReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := update_adm_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn update_adm_usecase(pool &dbpool.DatabasePoolable, req UpdateAdmReq) !UpdateAdmResp {
	update_adm_domain(req)!
	return update_adm_repo(pool, req)
}

// ═══ Domain ═══
fn update_adm_domain(req UpdateAdmReq) ! {
	if req.id == '' {
		return error('Adm id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateAdmReq {
	id              string  @[json: 'id']
	parent_id       ?string @[json: 'parentId']
	region_id       ?string @[json: 'regionId']
	sys_adm_code    ?string @[json: 'sysAdmCode']
	sys_adm_name    ?string @[json: 'sysAdmName']
	name_local      ?string @[json: 'nameLocal']
	govt_code       ?string @[json: 'govtCode']
	gid_zero        ?string @[json: 'gidZero']
	hasc            ?string @[json: 'hasc']
	iso_two         ?string @[json: 'isoTwo']
	iso_three       ?string @[json: 'isoThree']
	numeric         ?string @[json: 'numeric']
	postal_code     ?string @[json: 'postalCode']
	level           ?u8     @[json: 'level']
	tree_id         ?string @[json: 'treeId']
	coord_bounds    ?string @[json: 'coordBounds']
	sort            ?u64    @[json: 'sort']
	status          ?u8     @[json: 'status']
	adm_merger_name ?string @[json: 'admMergerName']
	adm_short_name  ?string @[json: 'admShortName']
	pinyin          ?string @[json: 'pinyin']
	first           ?string @[json: 'first']
	name_en         ?string @[json: 'nameEn']
	name_zh         ?string @[json: 'nameZh']
}

pub struct UpdateAdmResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_adm_repo(pool &dbpool.DatabasePoolable, req UpdateAdmReq) !UpdateAdmResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// vfmt off
	up_expr := {
		if v := req.parent_id {
			parent_id == v
		},
		if v := req.region_id {
			region_id == v
		},
		if v := req.sys_adm_code {
			sys_adm_code == v
		},
		if v := req.sys_adm_name {
			sys_adm_name == v
		},
		if v := req.name_local {
			name_local == v
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
		if v := req.postal_code {
			postal_code == v
		},
		if v := req.level {
			level == v
		},
		if v := req.tree_id {
			tree_id == v
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
		if v := req.adm_merger_name {
			adm_merger_name == v
		},
		if v := req.adm_short_name {
			adm_short_name == v
		},
		if v := req.pinyin {
			pinyin == v
		},
		if v := req.first {
			first == v
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
		dynamic update BaseRegionAdmDiv set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateAdmResp{
		msg: 'Adm updated successfully'
	}
}
