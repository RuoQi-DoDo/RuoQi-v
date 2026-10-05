module region

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseRegion }

// ═══ Tool ═══
pub fn find_region_all_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_region_find_all'
		title:        'List regions'
		description:  'List base countries/regions with optional filters and pagination.'
		input_schema: '{"type":"object","properties":{"page":{"type":"integer","minimum":1,"description":"Page number, defaults to 1"},"pageSize":{"type":"integer","minimum":1,"description":"Page size, defaults to 20"},"sysRegionCode":{"type":"string"},"sysRegionName":{"type":"string"},"nameLocal":{"type":"string"},"langcodeLocal":{"type":"string"},"isoTwo":{"type":"string"},"isoThree":{"type":"string"},"numeric":{"type":"string"},"nameEn":{"type":"string"},"nameZh":{"type":"string"},"continentCode":{"type":"string"},"status":{"type":"array","items":{"type":"integer"}}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  true
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[RegionListReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := find_region_all_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn find_region_all_usecase(pool &dbpool.DatabasePoolable, req RegionListReq) !RegionListResp {
	find_region_all_domain()
	return find_region_all_repo(pool, req)
}

// ═══ Domain ═══
fn find_region_all_domain() {
}

// ═══ DTO ═══
pub struct RegionListReq {
	page                 int    @[json: 'page']
	page_size            int    @[json: 'pageSize']
	sys_region_code      string @[json: 'sysRegionCode']
	sys_region_name      string @[json: 'sysRegionName']
	name_local           string @[json: 'nameLocal']
	langcode_local       string @[json: 'langcodeLocal']
	govt_code            string @[json: 'govtCode']
	gid_zero             string @[json: 'gidZero']
	hasc                 string @[json: 'hasc']
	iso_two              string @[json: 'isoTwo']
	iso_three            string @[json: 'isoThree']
	numeric              string @[json: 'numeric']
	international_prefix string @[json: 'internationalPrefix']
	phone_area_code      string @[json: 'phoneAreaCode']
	postal_code          string @[json: 'postalCode']
	domain_name          string @[json: 'domainName']
	continent_code       string @[json: 'continentCode']
	coord_bounds         string @[json: 'coordBounds']
	status               []u8   @[json: 'status']
	name_en              string @[json: 'nameEn']
	name_zh              string @[json: 'nameZh']
}

pub struct RegionData {
	id                   string  @[json: 'id']
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
	updater_id           ?string @[json: 'updaterId']
	creator_id           ?string @[json: 'creatorId']
	created_at           string  @[json: 'createdAt']
	updated_at           string  @[json: 'updatedAt']
	deleted_at           string  @[json: 'deletedAt']
}

pub struct RegionListResp {
	total int
	data  []RegionData
}

// ═══ Repository ═══
fn find_region_all_repo(pool &dbpool.DatabasePoolable, req RegionListReq) !RegionListResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	page := if req.page <= 0 { 1 } else { req.page }
	page_size := if req.page_size <= 0 { 20 } else { req.page_size }

	// 总数统计
	mut count := sql db {
		select count from BaseRegion
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (page - 1) * page_size
	// vfmt off
	where_expr := {
			if req.sys_region_code != '' {sys_region_code == req.sys_region_code},
			if req.sys_region_name != '' {sys_region_name == req.sys_region_name},
			if req.name_local != '' {name_local == req.name_local},
			if req.langcode_local != '' {langcode_local == req.langcode_local},
			if req.govt_code != '' {govt_code == req.govt_code},
			if req.gid_zero != '' {gid_zero == req.gid_zero},
			if req.hasc != '' {hasc == req.hasc},
			if req.iso_two != '' {iso_two == req.iso_two},
			if req.iso_three != '' {iso_three == req.iso_three},
			if req.numeric != '' {numeric == req.numeric},
			if req.international_prefix != '' {international_prefix == req.international_prefix},
			if req.phone_area_code != '' {phone_area_code == req.phone_area_code},
			if req.postal_code != '' {postal_code == req.postal_code},
			if req.domain_name != '' {domain_name == req.domain_name},
			if req.continent_code != '' {continent_code == req.continent_code},
			if req.coord_bounds != '' {coord_bounds == req.coord_bounds},
			if req.status.len > 0 {status in req.status},
			if req.name_en != '' {name_en == req.name_en},
			if req.name_zh != '' {name_zh == req.name_zh}
	}
	// vfmt on
	result := sql db {
		dynamic select from BaseRegion where where_expr order by sort limit page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []RegionData{}
	for row in result {
		datalist << RegionData{
			id:                   row.id
			sys_region_code:      row.sys_region_code
			sys_region_name:      row.sys_region_name
			name_local:           row.name_local
			langcode_local:       row.langcode_local
			govt_code:            row.govt_code
			gid_zero:             row.gid_zero
			hasc:                 row.hasc
			iso_two:              row.iso_two
			iso_three:            row.iso_three
			numeric:              row.numeric
			international_prefix: row.international_prefix
			phone_area_code:      row.phone_area_code
			postal_code:          row.postal_code
			domain_name:          row.domain_name
			continent_code:       row.continent_code
			coord_bounds:         row.coord_bounds
			sort:                 row.sort
			status:               row.status
			name_en:              row.name_en
			name_zh:              row.name_zh
			updater_id:           row.updater_id
			creator_id:           row.creator_id
			created_at:           row.created_at.format_ss()
			updated_at:           row.updated_at.format_ss()
			deleted_at:           (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return RegionListResp{
		total: count
		data:  datalist
	}
}
