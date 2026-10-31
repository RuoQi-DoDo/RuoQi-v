module platform_configuration

import dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfConfig }
import common.api
import time

// ═══ Handler ═══
@['/update_config'; post]
pub fn (app &PlatformConfiguration) update_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateConfigReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_config_usecase(mut ctx Context, req UpdateConfigReq) !dto.MsgResp {
	update_config_domain(&req)!
	return update_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_config_domain(req &UpdateConfigReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateConfigReq {
	id          string  @[json: 'id'; description: '唯一标识']
	key         ?string @[json: 'key'; description: '键']
	value       ?string @[json: 'value'; description: '值']
	category    ?string @[json: 'category'; description: '分类']
	description ?string @[json: 'description'; description: '描述']
	status      ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_config_repo(mut ctx Context, req UpdateConfigReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.key {
			key == v
		},
		if v := req.value {
			value == v
		},
		if v := req.category {
			category == v
		},
		if v := req.description {
			description == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update PfConfig set up_expr where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Configuration updated'
	}
}
