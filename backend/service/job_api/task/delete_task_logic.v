module task

import dto
import time
import veb
import log
import json2 as json
import model.schema_job { JobTask }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &Task) delete_task_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[dto.DeleteIdsReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_task_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_task_usecase(mut ctx Context, req dto.DeleteIdsReq) !dto.MsgResp {
	delete_task_domain(&req)!
	return delete_task_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_task_domain(req &dto.DeleteIdsReq) ! {
	if req.ids.len == 0 {
		return error('No Task ids provided')
	}
}

// ═══ Repository ═══
fn delete_task_repo(mut ctx Context, ids []string) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update JobTask set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to delete task: ${err}') }

	return dto.MsgResp{
		msg: '${ids.len} Task(s) deleted successfully'
	}
}
