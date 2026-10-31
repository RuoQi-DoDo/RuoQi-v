module region

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_base { BaseRegion }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Region) create_region_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateRegionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_region_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_region_usecase(mut ctx Context, req CreateRegionReq) !dto.MsgResp {
	create_region_domain(&req)!
	return create_region_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_region_domain(req &CreateRegionReq) ! {
	if req.sys_region_code == '' {
		return error('sys_region_code is required')
	}
	if req.sys_region_name == '' {
		return error('sys_region_name is required')
	}
}

// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ═══ DTO ═══
pub struct CreateRegionReq {
	sys_region_code      string  @[json: 'sysRegionCode'; description: '系统地区代码']
	sys_region_name      string  @[json: 'sysRegionName'; description: '系统地区名称']
	name_local           string  @[json: 'nameLocal'; description: '本地名称']
	langcode_local       string  @[json: 'langcodeLocal'; description: '本地语言代码']
	govt_code            ?string @[json: 'govtCode'; description: '政府行政区划代码']
	gid_zero             ?string @[json: 'gidZero'; description: 'GID 零级代码']
	hasc                 ?string @[json: 'hasc'; description: 'HASC 行政区划代码']
	iso_two              ?string @[json: 'isoTwo'; description: 'ISO 两位代码']
	iso_three            ?string @[json: 'isoThree'; description: 'ISO 三位代码']
	numeric              ?string @[json: 'numeric'; description: 'ISO 数字代码']
	international_prefix ?string @[json: 'internationalPrefix'; description: '国际电话前缀']
	phone_area_code      ?string @[json: 'phoneAreaCode'; description: '电话区号']
	postal_code          ?string @[json: 'postalCode'; description: '邮政编码']
	domain_name          ?string @[json: 'domainName'; description: '域名']
	continent_code       ?string @[json: 'continentCode'; description: '大洲代码']
	coord_bounds         ?string @[json: 'coordBounds'; description: '坐标边界']
	sort                 ?int    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status               u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	name_en              ?string @[json: 'nameEn'; description: '英文名称']
	name_zh              ?string @[json: 'nameZh'; description: '中文名称']
	updater_id           ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id           ?string @[json: 'creatorId'; description: '创建者 ID']
}

// ═══ Repository ═══
fn create_region_repo(mut ctx Context, req CreateRegionReq) !dto.MsgResp {
	time_now := time.now()
	base_region := BaseRegion{
		id:                   rand.uuid_v7()
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
		updater_id:           ctx.svc_iam.user_id
		creator_id:           ctx.svc_iam.user_id
		created_at:           time_now
		updated_at:           time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_region into BaseRegion
	} or { return error('Failed to create Region: ${err}') }

	return dto.MsgResp{
		msg: 'Region created successfully'
	}
}
