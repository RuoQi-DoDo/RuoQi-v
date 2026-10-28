module platform_configuration

import common.dto
import veb
import log
import json2 as json
import model { Context }
import model.schema_platform { PfConfig }
import common.api

// ═══ Handler ═══
@['/delete_config'; post]
pub fn (app &PlatformConfiguration) delete_config_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[dto.IdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_config_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: err.msg()))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_config_usecase(mut ctx Context, req dto.IdReq) !dto.MsgResp {
	delete_config_domain(&req)!
	return delete_config_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_config_domain(req &dto.IdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ Repository ═══
fn delete_config_repo(mut ctx Context, req dto.IdReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update PfConfig set del_flag = -1 where id == req.id
	}!
	return dto.MsgResp{
		msg: 'Configuration deleted'
	}
}
