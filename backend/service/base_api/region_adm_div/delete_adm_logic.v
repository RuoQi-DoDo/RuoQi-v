module region_adm_div

import dto
import time
import veb
import log
import json2 as json
import model.schema_base { BaseRegionAdmDiv }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &RegionAdmDiv) delete_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[dto.DeleteIdsReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	// Usecase 执行
	result := delete_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_adm_usecase(mut ctx Context, req dto.DeleteIdsReq) !dto.MsgResp {
	// Domain 校验
	delete_adm_domain(&req)!

	// Repository 执行删除
	return delete_adm_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_adm_domain(req &dto.DeleteIdsReq) ! {
	if req.ids.len == 0 {
		return error('No Adm ids provided')
	}
}

// ═══ Repository ═══
fn delete_adm_repo(mut ctx Context, adm_ids []string) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update BaseRegionAdmDiv set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in adm_ids && del_flag == 0
	} or { return error('Failed to soft-delete adm: ${err}') }

	return dto.MsgResp{
		msg: '${adm_ids} token(s) deleted successfully'
	}
}
