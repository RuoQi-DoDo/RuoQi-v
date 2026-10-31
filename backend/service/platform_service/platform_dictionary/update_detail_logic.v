module platform_dictionary

import dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfDictionaryDetail }
import common.api
import time

// ═══ Handler ═══
@['/update_detail'; post]
pub fn (app &PlatformDictionary) update_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_detail_usecase(mut ctx Context, req UpdateDetailReq) !dto.MsgResp {
	update_detail_domain(&req)!
	return update_detail_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_detail_domain(req &UpdateDetailReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateDetailReq {
	id     string  @[json: 'id'; description: '唯一标识']
	label  ?string @[json: 'label'; description: '显示标签']
	value  ?string @[json: 'value'; description: '值']
	sort   ?u32    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

// ═══ Repository ═══
fn update_detail_repo(mut ctx Context, req UpdateDetailReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	// vfmt off
	up_expr := {
		if v := req.label {
			label == v
		},
		if v := req.value {
			value == v
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
		dynamic update PfDictionaryDetail set up_expr where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Detail updated'
	}
}
