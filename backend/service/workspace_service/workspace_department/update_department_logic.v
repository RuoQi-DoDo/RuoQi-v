module workspace_department

import dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_workspace { WsDepartment }
import common.api
import time

// ═══ Handler ═══
@['/update_department'; post]
pub fn (app &WorkspaceDepartment) update_department_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDepartmentReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_department_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_department_usecase(mut ctx Context, req UpdateDepartmentReq) !dto.MsgResp {
	update_department_domain(&req)!
	return update_department_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_department_domain(req &UpdateDepartmentReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateDepartmentReq {
	id          string  @[json: 'id'; description: '唯一标识']
	parent_id   ?string @[json: 'parentId'; description: '父级 ID']
	name        ?string @[json: 'name'; description: '名称']
	code        ?string @[json: 'code'; description: '编码']
	description ?string @[json: 'description'; description: '描述']
	sort        ?u32    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status      ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_department_repo(mut ctx Context, req UpdateDepartmentReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.parent_id {
			parent_id == v
		},
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
		dynamic update WsDepartment set up_expr where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Department updated'
	}
}
