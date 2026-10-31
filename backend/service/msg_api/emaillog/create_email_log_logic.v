module emaillog

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &EmailLog) create_email_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateEmailLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_email_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_email_log_usecase(mut ctx Context, req CreateEmailLogReq) !dto.MsgResp {
	create_email_log_domain(&req)!
	return create_email_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_email_log_domain(req &CreateEmailLogReq) ! {
	if req.target == '' {
		return error('target email address is required')
	}
	if req.subject == '' {
		return error('subject is required')
	}
	if req.provider == '' {
		return error('provider is required')
	}
}

// ═══ DTO ═══
pub struct CreateEmailLogReq {
	target      string @[json: 'target'; description: '目标']
	subject     string @[json: 'subject'; description: '交易标题']
	content     string @[json: 'content'; description: '内容']
	send_status u8     @[json: 'sendStatus'; description: '发送状态：0 未知，1 成功，2 失败']
	provider    string @[json: 'provider'; description: '服务提供商']
}

// ═══ Repository ═══
fn create_email_log_repo(mut ctx Context, req CreateEmailLogReq) !dto.MsgResp {
	time_now := time.now()
	email_log := MsgEmailLog{
		id:          rand.uuid_v7()
		target:      req.target
		subject:     req.subject
		content:     req.content
		send_status: req.send_status
		provider:    req.provider
		creator_id:  ctx.svc_iam.user_id
		updater_id:  ctx.svc_iam.user_id
		created_at:  time_now
		updated_at:  time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert email_log into MsgEmailLog
	} or { return error('Failed to create EmailLog: ${err}') }

	return dto.MsgResp{
		msg: 'EmailLog created successfully'
	}
}
