module emailprovider

import veb
import log
import time
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &EmailProvider) find_email_provider_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailProviderListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_provider_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_provider_all_usecase(mut ctx Context, req EmailProviderListReq) !EmailProviderListResp {
	find_email_provider_all_domain()
	return find_email_provider_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_provider_all_domain() {
}

// ═══ DTO ═══
pub struct EmailProviderListReq {
	page       int    @[json: 'page'; description: '页码，从 1 开始']
	page_size  int    @[json: 'pageSize'; description: '每页记录数']
	name       string @[json: 'name'; description: '名称']
	email_addr string @[json: 'emailAddr'; description: '邮箱地址']
}

pub struct EmailProviderData {
	id         string  @[json: 'id'; description: '唯一标识']
	name       string  @[json: 'name'; description: '邮件提供商名称']
	auth_type  u8      @[json: 'authType'; description: '认证类型']
	email_addr string  @[json: 'emailAddr'; description: '发件邮箱地址']
	host_name  string  @[json: 'hostName'; description: '邮件服务器主机名']
	port       ?u32    @[json: 'port'; description: '邮件服务器端口']
	tls        u8      @[json: 'tls'; description: '是否启用 TLS：0 否，1 是']
	is_default u8      @[json: 'isDefault'; description: '是否默认提供商：0 否，1 是']
	updater_id ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at string  @[json: 'createdAt'; description: '创建时间']
	updated_at string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct EmailProviderListResp {
	total int                 @[description: '总记录数']
	data  []EmailProviderData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_email_provider_all_repo(mut ctx Context, req EmailProviderListReq) !EmailProviderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from MsgEmailProvider
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.name != '' {name == req.name},
		if req.email_addr != '' {email_addr == req.email_addr}
	}
	// vfmt on
	result := sql db {
		dynamic select from MsgEmailProvider where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []EmailProviderData{}
	for row in result {
		datalist << EmailProviderData{
			id:         row.id
			name:       row.name
			auth_type:  row.auth_type
			email_addr: row.email_addr
			host_name:  row.host_name
			port:       row.port
			tls:        row.tls
			is_default: row.is_default
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return EmailProviderListResp{
		total: count
		data:  datalist
	}
}
