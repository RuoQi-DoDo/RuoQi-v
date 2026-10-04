module region_adm_div

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseRegionAdmDiv }

// ═══ Tool ═══
pub fn find_region_adm_all_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_adm_div_find_all'
		title:        'List administrative divisions'
		description:  'List country/region administrative divisions filtered by region (country) and optional parent, with pagination.'
		input_schema: '{"type":"object","properties":{"regionId":{"type":"string","description":"Country/region id (base_region.id)"},"parentId":{"type":"string","description":"Parent administrative division id"},"page":{"type":"integer","minimum":1,"description":"Page number, defaults to 1"},"pageSize":{"type":"integer","minimum":1,"description":"Page size, defaults to 20"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  true
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[RegionAdmListReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := find_region_adm_all_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn find_region_adm_all_usecase(pool &dbpool.DatabasePoolable, req RegionAdmListReq) !RegionAdmListResp {
	find_region_adm_all_domain()
	return find_region_adm_all_repo(pool, req)
}

// ═══ Domain ═══
fn find_region_adm_all_domain() {
}

// ═══ DTO ═══
pub struct RegionAdmListReq {
	region_id string @[json: 'regionId']
	parent_id string @[json: 'parentId']
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
}

pub struct RegionAdmData {
	id              string  @[json: 'id']
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
	updater_id      ?string @[json: 'updaterId']
	creator_id      ?string @[json: 'creatorId']
	created_at      string  @[json: 'createdAt']
	updated_at      string  @[json: 'updatedAt']
	deleted_at      string  @[json: 'deletedAt']
}

pub struct RegionAdmListResp {
	total int
	data  []RegionAdmData
}

// ═══ Repository ═══
fn find_region_adm_all_repo(pool &dbpool.DatabasePoolable, req RegionAdmListReq) !RegionAdmListResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	page := if req.page <= 0 { 1 } else { req.page }
	page_size := if req.page_size <= 0 { 20 } else { req.page_size }

	mut count := sql db {
		select count from BaseRegionAdmDiv
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (page - 1) * page_size
	// vfmt off
	where_expr := {
			if req.region_id != '' {region_id == req.region_id},
			if req.parent_id != '' {parent_id == req.parent_id}
	}
	// vfmt on
	result := sql db {
		dynamic select from BaseRegionAdmDiv where where_expr order by sort limit page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []RegionAdmData{}
	for row in result {
		datalist << RegionAdmData{
			id:              row.id
			parent_id:       row.parent_id
			region_id:       row.region_id
			sys_adm_code:    row.sys_adm_code
			sys_adm_name:    row.sys_adm_name
			name_local:      row.name_local
			govt_code:       row.govt_code
			gid_zero:        row.gid_zero
			hasc:            row.hasc
			iso_two:         row.iso_two
			iso_three:       row.iso_three
			numeric:         row.numeric
			postal_code:     row.postal_code
			level:           row.level
			tree_id:         row.tree_id
			coord_bounds:    row.coord_bounds
			sort:            row.sort
			status:          row.status
			adm_merger_name: row.adm_merger_name
			adm_short_name:  row.adm_short_name
			pinyin:          row.pinyin
			first:           row.first
			name_en:         row.name_en
			name_zh:         row.name_zh
			updater_id:      row.updater_id
			creator_id:      row.creator_id
			created_at:      row.created_at.format_ss()
			updated_at:      row.updated_at.format_ss()
			deleted_at:      (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return RegionAdmListResp{
		total: count
		data:  datalist
	}
}
