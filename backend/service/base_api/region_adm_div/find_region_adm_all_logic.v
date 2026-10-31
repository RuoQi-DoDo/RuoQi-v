module region_adm_div

import veb
import log
import time
import json2 as json
import model.schema_base { BaseRegionAdmDiv }
import common.api
import model { Context }

// ═══ Handler ═══
@['/all'; get]
pub fn (app &RegionAdmDiv) find_region_adm_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RegionAdmListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_region_adm_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_region_adm_all_usecase(mut ctx Context, req RegionAdmListReq) !RegionAdmListResp {
	find_region_adm_all_domain()
	return find_region_adm_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_region_adm_all_domain() {
}

// ═══ DTO ═══
pub struct RegionAdmListReq {
	region_id string @[json: 'regionId'; description: '地区 ID']
}

pub struct RegionAdmData {
	id              string  @[json: 'id'; description: '唯一标识']
	parent_id       string  @[json: 'parentId'; description: '父级行政区划 ID']
	region_id       string  @[json: 'regionId'; description: '所属地区 ID']
	sys_adm_code    string  @[json: 'sysAdmCode'; description: '系统行政区划代码']
	sys_adm_name    string  @[json: 'sysAdmName'; description: '系统行政区划名称']
	name_local      ?string @[json: 'nameLocal'; description: '本地语言名称']
	govt_code       ?string @[json: 'govtCode'; description: '政府代码']
	gid_zero        ?string @[json: 'gidZero'; description: 'GID 零级编码']
	hasc            ?string @[json: 'hasc'; description: 'HASC 编码']
	iso_two         ?string @[json: 'isoTwo'; description: '两位 ISO 代码']
	iso_three       ?string @[json: 'isoThree'; description: '三位 ISO 代码']
	numeric         ?string @[json: 'numeric'; description: '数字代码']
	postal_code     ?string @[json: 'postalCode'; description: '邮政编码']
	level           u8      @[json: 'level'; description: '行政区划层级']
	tree_id         string  @[json: 'treeId'; description: '树形结构路径 ID']
	coord_bounds    ?string @[json: 'coordBounds'; description: '坐标边界']
	sort            ?u64    @[json: 'sort'; description: '排序值']
	status          u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	adm_merger_name ?string @[json: 'admMergerName'; description: '行政区划合并名称']
	adm_short_name  ?string @[json: 'admShortName'; description: '行政区划简称']
	pinyin          ?string @[json: 'pinyin'; description: '拼音']
	first           string  @[json: 'first'; description: '名称首字母']
	name_en         ?string @[json: 'nameEn'; description: '英文名称']
	name_zh         ?string @[json: 'nameZh'; description: '中文名称']
	updater_id      ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id      ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at      string  @[json: 'createdAt'; description: '创建时间']
	updated_at      string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at      string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct RegionAdmListResp {
	total int             @[description: '总记录数']
	data  []RegionAdmData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_region_adm_all_repo(mut ctx Context, req RegionAdmListReq) !RegionAdmListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	result := sql db {
		select from BaseRegionAdmDiv where id == req.region_id
	} or { return error('Failed to execute SQL query: ${err}') }

	if result.len == 0 {
		return error('BaseRegionAdmDiv not found')
	}

	// 构造返回数据
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
		data: datalist
	}
}
