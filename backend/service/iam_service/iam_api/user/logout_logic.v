module user

import dto
import veb
import log
import model { Context }
import model.schema_iam { IamToken }
import common.api

// ═══ Handler ═══
@['/logout'; get; post]
pub fn (app &User) logout_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := logout_usecase(mut ctx) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn logout_usecase(mut ctx Context) !dto.MsgResp {
	logout_repo(mut ctx)!
	return dto.MsgResp{
		msg: 'Logout successful'
	}
}

// ═══ Repository ═══
fn logout_repo(mut ctx Context) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamToken set status = 0 where user_id == ctx.svc_iam.user_id
	}!
}
