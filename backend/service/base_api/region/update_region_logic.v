module region

import dto
import veb
import log
import time
import json2 as json
import model.schema_base { BaseRegion }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Region) update_region_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateRegionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_region_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_region_usecase(mut ctx Context, req UpdateRegionReq) !dto.MsgResp {
	// Domain 校验
	update_region_domain(&req)!

	// Repository 更新
	return update_region_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_region_domain(req &UpdateRegionReq) ! {
	if req.id == '' {
		return error('region id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateRegionReq {
	id                   string  @[json: 'id'; description: '唯一标识']
	sys_region_code      ?string @[json: 'sysRegionCode'; description: '系统地区代码']
	sys_region_name      ?string @[json: 'sysRegionName'; description: '系统地区名称']
	name_local           ?string @[json: 'nameLocal'; description: '本地名称']
	langcode_local       ?string @[json: 'langcodeLocal'; description: '本地语言代码']
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
	status               ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
	name_en              ?string @[json: 'nameEn'; description: '英文名称']
	name_zh              ?string @[json: 'nameZh'; description: '中文名称']
}

// ═══ Repository ═══
fn update_region_repo(mut ctx Context, req UpdateRegionReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.sys_region_code {
			sys_region_code == v
		},
		if v := req.sys_region_name {
			sys_region_name == v
		},
		if v := req.name_local {
			name_local == v
		},
		if v := req.langcode_local {
			langcode_local == v
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
		if v := req.international_prefix {
			international_prefix == v
		},
		if v := req.phone_area_code {
			phone_area_code == v
		},
		if v := req.postal_code {
			postal_code == v
		},
		if v := req.domain_name {
			domain_name == v
		},
		if v := req.continent_code {
			continent_code == v
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
		dynamic update BaseRegion set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'regiion updated successfully'
	}
}
