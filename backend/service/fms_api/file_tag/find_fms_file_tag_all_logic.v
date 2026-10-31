module file_tag

import veb
import log
import time
import model.schema_fms { FmsFileTag }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &FileTag) find_fms_file_tag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsFileTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_file_tag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_file_tag_all_usecase(mut ctx Context, req FmsFileTagListReq) !FmsFileTagListResp {
	find_fms_file_tag_all_domain(&req)!
	return find_fms_file_tag_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_file_tag_all_domain(req &FmsFileTagListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct FmsFileTagListReq {
	page      int    @[json: 'page'; description: '页码，从 1 开始']
	page_size int    @[json: 'pageSize'; description: '每页记录数']
	name      string @[json: 'name'; description: '名称']
	status    []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct FmsFileTagData {
	id         string  @[json: 'id'; description: '唯一标识']
	name       string  @[json: 'name'; description: '文件标签名称']
	remark     ?string @[json: 'remark'; description: '备注']
	status     u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	updater_id ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at string  @[json: 'createdAt'; description: '创建时间']
	updated_at string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct FmsFileTagListResp {
	total int              @[description: '总记录数']
	data  []FmsFileTagData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_fms_file_tag_all_repo(mut ctx Context, req FmsFileTagListReq) !FmsFileTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from FmsFileTag where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.name != '' {name == req.name},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from FmsFileTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []FmsFileTagData{}
	for row in result {
		datalist << FmsFileTagData{
			id:         row.id
			name:       row.name
			remark:     row.remark
			status:     row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return FmsFileTagListResp{
		total: count
		data:  datalist
	}
}
