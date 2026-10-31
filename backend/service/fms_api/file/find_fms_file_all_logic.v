module file

import veb
import log
import time
import model.schema_fms { FmsFile }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &File) find_fms_file_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsFileListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_file_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_file_all_usecase(mut ctx Context, req FmsFileListReq) !FmsFileListResp {
	find_fms_file_all_domain(&req)!
	return find_fms_file_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_file_all_domain(req &FmsFileListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct FmsFileListReq {
	page      int    @[json: 'page'; description: '页码，从 1 开始']
	page_size int    @[json: 'pageSize'; description: '每页记录数']
	name      string @[json: 'name'; description: '名称']
	user_id   string @[json: 'userId'; description: '用户 ID']
	file_type []u8   @[json: 'fileType'; description: '文件类型']
	status    []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct FmsFileData {
	id         string  @[json: 'id'; description: '唯一标识']
	name       string  @[json: 'name'; description: '文件名称']
	file_type  u8      @[json: 'fileType'; description: '文件类型']
	size       u64     @[json: 'size'; description: '文件大小（字节）']
	path       string  @[json: 'path'; description: '文件路径']
	user_id    string  @[json: 'userId'; description: '所属用户 ID']
	md5        string  @[json: 'md5'; description: '文件 MD5 摘要']
	status     u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	updater_id ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at string  @[json: 'createdAt'; description: '创建时间']
	updated_at string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct FmsFileListResp {
	total int           @[description: '总记录数']
	data  []FmsFileData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_fms_file_all_repo(mut ctx Context, req FmsFileListReq) !FmsFileListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from FmsFile where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.name != '' {name == req.name},
		if req.user_id != '' {user_id == req.user_id},
		if req.file_type.len > 0 {file_type in req.file_type},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from FmsFile where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []FmsFileData{}
	for row in result {
		datalist << FmsFileData{
			id:         row.id
			name:       row.name
			file_type:  row.file_type
			size:       row.size
			path:       row.path
			user_id:    row.user_id
			md5:        row.md5
			status:     row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return FmsFileListResp{
		total: count
		data:  datalist
	}
}
