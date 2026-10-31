module workspace_position

import dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsPosition }
import common.api
import time

// ═══ Handler ═══
@['/update_position'; post]
pub fn (app &WorkspacePosition) update_position_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdatePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_position_usecase(mut ctx Context, req UpdatePositionReq) !dto.MsgResp {
	update_position_domain(&req)!
	return update_position_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_position_domain(req &UpdatePositionReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePositionReq {
	id          string  @[json: 'id'; description: '唯一标识']
	name        ?string @[json: 'name'; description: '名称']
	code        ?string @[json: 'code'; description: '编码']
	description ?string @[json: 'description'; description: '描述']
	sort        ?u32    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status      ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_position_repo(mut ctx Context, req UpdatePositionReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.name {
			name == v
		},
		if v := req.code {
			code == v
		},
		if v := req.description {
			description == v
		},
		if v := req.sort {
			sort == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update WsPosition set up_expr where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Position updated'
	}
}
