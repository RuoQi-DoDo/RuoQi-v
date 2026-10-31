module cloud_file

import veb
import log
import time
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &CloudFile) find_fms_cloud_file_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsCloudFileListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_cloud_file_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_cloud_file_all_usecase(mut ctx Context, req FmsCloudFileListReq) !FmsCloudFileListResp {
	find_fms_cloud_file_all_domain(&req)!
	return find_fms_cloud_file_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_cloud_file_all_domain(req &FmsCloudFileListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct FmsCloudFileListReq {
	page      int    @[json: 'page'; description: '页码，从 1 开始']
	page_size int    @[json: 'pageSize'; description: '每页记录数']
	name      string @[json: 'name'; description: '名称']
	user_id   string @[json: 'userId'; description: '用户 ID']
	file_type []u8   @[json: 'fileType'; description: '文件类型']
	status    []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct FmsCloudFileData {
	id                           string  @[json: 'id'; description: '唯一标识']
	name                         string  @[json: 'name'; description: '云文件名称']
	url                          string  @[json: 'url'; description: '云文件资源地址']
	size                         u64     @[json: 'size'; description: '文件大小（字节）']
	file_type                    u8      @[json: 'fileType'; description: '文件类型']
	user_id                      string  @[json: 'userId'; description: '所属用户 ID']
	cloud_file_storage_providers ?string @[json: 'cloudFileStorageProviders'; description: '云文件存储提供商 ID']
	status                       u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	updater_id                   ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id                   ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at                   string  @[json: 'createdAt'; description: '创建时间']
	updated_at                   string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at                   string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct FmsCloudFileListResp {
	total int                @[description: '总记录数']
	data  []FmsCloudFileData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_fms_cloud_file_all_repo(mut ctx Context, req FmsCloudFileListReq) !FmsCloudFileListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from FmsCloudFile where del_flag == 0
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
		dynamic select from FmsCloudFile where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []FmsCloudFileData{}
	for row in result {
		datalist << FmsCloudFileData{
			id:                           row.id
			name:                         row.name
			url:                          row.url
			size:                         row.size
			file_type:                    row.file_type
			user_id:                      row.user_id
			cloud_file_storage_providers: row.cloud_file_storage_providers
			status:                       row.status
			creator_id:                   row.creator_id
			updater_id:                   row.updater_id
			created_at:                   row.created_at.format_ss()
			updated_at:                   row.updated_at.format_ss()
			deleted_at:                   (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return FmsCloudFileListResp{
		total: count
		data:  datalist
	}
}
