module region_adm_div

import dto
import veb
import log
import time
import json2 as json
import model.schema_base { BaseRegionAdmDiv }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &RegionAdmDiv) update_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_adm_usecase(mut ctx Context, req UpdateAdmReq) !dto.MsgResp {
	// Domain 校验
	update_adm_domain(&req)!

	// Repository 更新
	return update_adm_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_adm_domain(req &UpdateAdmReq) ! {
	if req.id == '' {
		return error('Adm id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateAdmReq {
	id              string  @[json: 'id'; description: '唯一标识']
	parent_id       ?string @[json: 'parentId'; description: '父级 ID']
	region_id       ?string @[json: 'regionId'; description: '地区 ID']
	sys_adm_code    ?string @[json: 'sysAdmCode'; description: '系统行政区划代码']
	sys_adm_name    ?string @[json: 'sysAdmName'; description: '系统行政区划名称']
	name_local      ?string @[json: 'nameLocal'; description: '本地名称']
	govt_code       ?string @[json: 'govtCode'; description: '政府行政区划代码']
	gid_zero        ?string @[json: 'gidZero'; description: 'GID 零级代码']
	hasc            ?string @[json: 'hasc'; description: 'HASC 行政区划代码']
	iso_two         ?string @[json: 'isoTwo'; description: 'ISO 两位代码']
	iso_three       ?string @[json: 'isoThree'; description: 'ISO 三位代码']
	numeric         ?string @[json: 'numeric'; description: 'ISO 数字代码']
	postal_code     ?string @[json: 'postalCode'; description: '邮政编码']
	level           ?u8     @[json: 'level'; description: '层级']
	tree_id         ?string @[json: 'treeId'; description: '树形结构 ID']
	coord_bounds    ?string @[json: 'coordBounds'; description: '坐标边界']
	sort            ?u64    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status          ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
	adm_merger_name ?string @[json: 'admMergerName'; description: '行政区划完整名称']
	adm_short_name  ?string @[json: 'admShortName'; description: '行政区划简称']
	pinyin          ?string @[json: 'pinyin'; description: '拼音']
	first           ?string @[json: 'first'; description: '首字母']
	name_en         ?string @[json: 'nameEn'; description: '英文名称']
	name_zh         ?string @[json: 'nameZh'; description: '中文名称']
}

// ═══ Repository ═══
fn update_adm_repo(mut ctx Context, req UpdateAdmReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

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
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseRegionAdmDiv set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'Adm updated successfully'
	}
}
