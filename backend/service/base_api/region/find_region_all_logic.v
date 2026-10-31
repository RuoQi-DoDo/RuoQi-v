module region

import veb
import log
import time
import model.schema_base { BaseRegion }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Region) find_region_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RegionListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_region_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_region_all_usecase(mut ctx Context, req RegionListReq) !RegionListResp {
	find_region_all_domain()
	return find_region_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_region_all_domain() {
}

// ═══ DTO ═══
pub struct RegionListReq {
	page                 int    @[json: 'page'; description: '页码，从 1 开始']
	page_size            int    @[json: 'pageSize'; description: '每页记录数']
	sys_region_code      string @[json: 'sysRegionCode'; description: '系统地区代码']
	sys_region_name      string @[json: 'sysRegionName'; description: '系统地区名称']
	name_local           string @[json: 'nameLocal'; description: '本地名称']
	langcode_local       string @[json: 'langcodeLocal'; description: '本地语言代码']
	govt_code            string @[json: 'govtCode'; description: '政府行政区划代码']
	gid_zero             string @[json: 'gidZero'; description: 'GID 零级代码']
	hasc                 string @[json: 'hasc'; description: 'HASC 行政区划代码']
	iso_two              string @[json: 'isoTwo'; description: 'ISO 两位代码']
	iso_three            string @[json: 'isoThree'; description: 'ISO 三位代码']
	numeric              string @[json: 'numeric'; description: 'ISO 数字代码']
	international_prefix string @[json: 'internationalPrefix'; description: '国际电话前缀']
	phone_area_code      string @[json: 'phoneAreaCode'; description: '电话区号']
	postal_code          string @[json: 'postalCode'; description: '邮政编码']
	domain_name          string @[json: 'domainName'; description: '域名']
	continent_code       string @[json: 'continentCode'; description: '大洲代码']
	coord_bounds         string @[json: 'coordBounds'; description: '坐标边界']
	status               []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
	name_en              string @[json: 'nameEn'; description: '英文名称']
	name_zh              string @[json: 'nameZh'; description: '中文名称']
}

pub struct RegionData {
	id                   string  @[json: 'id'; description: '唯一标识']
	sys_region_code      string  @[json: 'sysRegionCode'; description: '系统地区代码']
	sys_region_name      string  @[json: 'sysRegionName'; description: '系统地区名称']
	name_local           string  @[json: 'nameLocal'; description: '本地语言名称']
	langcode_local       string  @[json: 'langcodeLocal'; description: '本地语言代码']
	govt_code            ?string @[json: 'govtCode'; description: '政府代码']
	gid_zero             ?string @[json: 'gidZero'; description: 'GID 零级编码']
	hasc                 ?string @[json: 'hasc'; description: 'HASC 编码']
	iso_two              ?string @[json: 'isoTwo'; description: '两位 ISO 国家/地区代码']
	iso_three            ?string @[json: 'isoThree'; description: '三位 ISO 国家/地区代码']
	numeric              ?string @[json: 'numeric'; description: 'ISO 数字代码']
	international_prefix ?string @[json: 'internationalPrefix'; description: '国际电话前缀']
	phone_area_code      ?string @[json: 'phoneAreaCode'; description: '电话区号']
	postal_code          ?string @[json: 'postalCode'; description: '邮政编码']
	domain_name          ?string @[json: 'domainName'; description: '域名']
	continent_code       ?string @[json: 'continentCode'; description: '所属大洲代码']
	coord_bounds         ?string @[json: 'coordBounds'; description: '坐标边界']
	sort                 ?int    @[json: 'sort'; description: '排序值']
	status               u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	name_en              ?string @[json: 'nameEn'; description: '英文名称']
	name_zh              ?string @[json: 'nameZh'; description: '中文名称']
	updater_id           ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id           ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at           string  @[json: 'createdAt'; description: '创建时间']
	updated_at           string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at           string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct RegionListResp {
	total int          @[description: '总记录数']
	data  []RegionData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_region_all_repo(mut ctx Context, req RegionListReq) !RegionListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseRegion
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
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
		dynamic select from BaseRegion where where_expr order by sort limit req.page_size offset offset_num
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
