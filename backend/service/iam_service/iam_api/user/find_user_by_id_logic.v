module user

import common.dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamUser }
import common.api

// ═══ Handler ═══
@['/find_user_by_id'; post]
pub fn (app &User) find_user_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[dto.IdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_user_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_user_by_id_usecase(mut ctx Context, req dto.IdReq) !IamUser {
	find_user_by_id_domain(&req)!
	return find_user_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_user_by_id_domain(req &dto.IdReq) ! {
	if req.id == '' {
		return error('user id is required')
	}
}

// ═══ Repository ═══
fn find_user_by_id_repo(mut ctx Context, req dto.IdReq) !IamUser {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	users := sql db {
		select from IamUser where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }
	if users.len == 0 {
		return error('user not found')
	}
	return users[0]
}
