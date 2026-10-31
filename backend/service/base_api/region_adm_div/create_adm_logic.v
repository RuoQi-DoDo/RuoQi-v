module region_adm_div

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_base { BaseRegionAdmDiv }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &RegionAdmDiv) create_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_adm_usecase(mut ctx Context, req CreateAdmReq) !dto.MsgResp {
	// create_adm_domain(&req)!
	return create_adm_repo(mut ctx, req)
}

// ═══ Domain ═══
// fn create_adm_domain(req CreateAdmReq) ! {
// if req.path == '' {
// 	return error('path is required')
// }
// if req.method == '' {
// 	return error('method is required')
// }
// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ═══ DTO ═══
pub struct CreateAdmReq {
	parent_id       string  @[json: 'parentId'; description: '父级 ID']
	region_id       string  @[json: 'regionId'; description: '地区 ID']
	sys_adm_code    string  @[json: 'sysAdmCode'; description: '系统行政区划代码']
	sys_adm_name    string  @[json: 'sysAdmName'; description: '系统行政区划名称']
	name_local      ?string @[json: 'nameLocal'; description: '本地名称']
	govt_code       ?string @[json: 'govtCode'; description: '政府行政区划代码']
	gid_zero        ?string @[json: 'gidZero'; description: 'GID 零级代码']
	hasc            ?string @[json: 'hasc'; description: 'HASC 行政区划代码']
	iso_two         ?string @[json: 'isoTwo'; description: 'ISO 两位代码']
	iso_three       ?string @[json: 'isoThree'; description: 'ISO 三位代码']
	numeric         ?string @[json: 'numeric'; description: 'ISO 数字代码']
	postal_code     ?string @[json: 'postalCode'; description: '邮政编码']
	level           u8      @[json: 'level'; description: '层级']
	tree_id         string  @[json: 'treeId'; description: '树形结构 ID']
	coord_bounds    ?string @[json: 'coordBounds'; description: '坐标边界']
	sort            ?u64    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status          u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	adm_merger_name ?string @[json: 'admMergerName'; description: '行政区划完整名称']
	adm_short_name  ?string @[json: 'admShortName'; description: '行政区划简称']
	pinyin          ?string @[json: 'pinyin'; description: '拼音']
	first           string  @[json: 'first'; description: '首字母']
	name_en         ?string @[json: 'nameEn'; description: '英文名称']
	name_zh         ?string @[json: 'nameZh'; description: '中文名称']
	updater_id      ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id      ?string @[json: 'creatorId'; description: '创建者 ID']
}

// ═══ Repository ═══
fn create_adm_repo(mut ctx Context, req CreateAdmReq) !dto.MsgResp {
	time_now := time.now()
	base_region := BaseRegionAdmDiv{
		id:              rand.uuid_v7()
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
		level:           req.level
		tree_id:         req.tree_id
		coord_bounds:    req.coord_bounds
		sort:            req.sort
		status:          req.status
		adm_merger_name: req.adm_merger_name
		adm_short_name:  req.adm_short_name
		pinyin:          req.pinyin
		first:           req.first
		name_en:         req.name_en
		name_zh:         req.name_zh
		updater_id:      ctx.svc_iam.user_id
		creator_id:      ctx.svc_iam.user_id
		created_at:      time_now
		updated_at:      time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_region into BaseRegionAdmDiv
	} or { return error('Failed to create Region: ${err}') }

	return dto.MsgResp{
		msg: 'Adm created successfully'
	}
}
