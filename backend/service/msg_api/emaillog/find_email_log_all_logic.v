module emaillog

import veb
import log
import time
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &EmailLog) find_email_log_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailLogListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_log_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_log_all_usecase(mut ctx Context, req EmailLogListReq) !EmailLogListResp {
	find_email_log_all_domain()
	return find_email_log_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_log_all_domain() {
}

// ═══ DTO ═══
pub struct EmailLogListReq {
	page        int    @[json: 'page'; description: '页码，从 1 开始']
	page_size   int    @[json: 'pageSize'; description: '每页记录数']
	target      string @[json: 'target'; description: '目标']
	subject     string @[json: 'subject'; description: '交易标题']
	provider    string @[json: 'provider'; description: '服务提供商']
	send_status []u8   @[json: 'sendStatus'; description: '发送状态：0 未知，1 成功，2 失败']
}

pub struct EmailLogData {
	id          string  @[json: 'id'; description: '唯一标识']
	target      string  @[json: 'target'; description: '目标邮箱地址']
	subject     string  @[json: 'subject'; description: '邮件主题']
	content     string  @[json: 'content'; description: '邮件内容']
	send_status u8      @[json: 'sendStatus'; description: '发送状态']
	provider    string  @[json: 'provider'; description: '邮件提供商']
	updater_id  ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id  ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at  string  @[json: 'createdAt'; description: '创建时间']
	updated_at  string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at  string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct EmailLogListResp {
	total int            @[description: '总记录数']
	data  []EmailLogData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_email_log_all_repo(mut ctx Context, req EmailLogListReq) !EmailLogListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from MsgEmailLog
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.target != '' {target == req.target},
		if req.subject != '' {subject == req.subject},
		if req.provider != '' {provider == req.provider},
		if req.send_status.len > 0 {send_status in req.send_status}
	}
	// vfmt on
	result := sql db {
		dynamic select from MsgEmailLog where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []EmailLogData{}
	for row in result {
		datalist << EmailLogData{
			id:          row.id
			target:      row.target
			subject:     row.subject
			content:     row.content
			send_status: row.send_status
			provider:    row.provider
			creator_id:  row.creator_id
			updater_id:  row.updater_id
			created_at:  row.created_at.format_ss()
			updated_at:  row.updated_at.format_ss()
			deleted_at:  (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return EmailLogListResp{
		total: count
		data:  datalist
	}
}
