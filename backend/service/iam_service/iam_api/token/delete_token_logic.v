module token

import common.dto
import time
import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/delete_token'; post]
pub fn (app &Token) delete_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[dto.IdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_token_usecase(mut ctx Context, req dto.IdReq) !map[string]string {
	delete_token_domain(&req)!
	delete_token_repo(mut ctx, req)!
	return {
		'msg': 'Token deleted successfully'
	}
}

// ═══ Domain ═══
fn delete_token_domain(req &dto.IdReq) ! {
	if req.id == '' {
		return error('token id is required')
	}
}

// ═══ Repository ═══
fn delete_token_repo(mut ctx Context, req dto.IdReq) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamToken set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id == req.id && del_flag == 0
	} or { return error('Failed to soft-delete token: ${err}') }
}
