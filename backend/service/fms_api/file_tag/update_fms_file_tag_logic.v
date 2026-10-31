module file_tag

import dto
import veb
import log
import time
import json2 as json
import model.schema_fms { FmsFileTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &FileTag) update_fms_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateFmsFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_fms_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_fms_file_tag_usecase(mut ctx Context, req UpdateFmsFileTagReq) !dto.MsgResp {
	update_fms_file_tag_domain(&req)!
	return update_fms_file_tag_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_fms_file_tag_domain(req &UpdateFmsFileTagReq) ! {
	if req.id == '' {
		return error('tag id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateFmsFileTagReq {
	id     string  @[json: 'id'; description: '唯一标识']
	name   ?string @[json: 'name'; description: '名称']
	remark ?string @[json: 'remark'; description: '备注']
	status ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_fms_file_tag_repo(mut ctx Context, req UpdateFmsFileTagReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	existing := sql db {
		select from FmsFileTag where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed to check existence: ${err}') }
	if existing.len == 0 {
		return error('FmsFileTag with id ${req.id} not found')
	}

	// vfmt off
	up_expr := {
		if v := req.name {
			name == v
		},
		if v := req.remark {
			remark == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update FmsFileTag set up_expr where id == req.id && del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'FmsFileTag updated successfully'
	}
}
