module cloud_file_tag

import veb
import log
import time
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }
import json2 as json

@['/all'; get]
pub fn (app &CloudFileTag) find_fms_cloud_file_tag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsCloudFileTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_fms_cloud_file_tag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn find_fms_cloud_file_tag_all_usecase(mut ctx Context, req FmsCloudFileTagListReq) !FmsCloudFileTagListResp {
	find_fms_cloud_file_tag_all_domain(&req)!
	return find_fms_cloud_file_tag_all_repo(mut ctx, req)
}

fn find_fms_cloud_file_tag_all_domain(req &FmsCloudFileTagListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

pub struct FmsCloudFileTagListReq {
	page      int    @[json: 'page'; description: '页码，从 1 开始']
	page_size int    @[json: 'pageSize'; description: '每页记录数']
	name      string @[json: 'name'; description: '名称']
	status    []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
}

pub struct FmsCloudFileTagData {
	id         string  @[json: 'id'; description: '唯一标识']
	name       string  @[json: 'name'; description: '云文件标签名称']
	remark     ?string @[json: 'remark'; description: '备注']
	status     u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	updater_id ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at string  @[json: 'createdAt'; description: '创建时间']
	updated_at string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct FmsCloudFileTagListResp {
	total int                   @[description: '总记录数']
	data  []FmsCloudFileTagData @[description: '响应数据']
}

fn find_fms_cloud_file_tag_all_repo(mut ctx Context, req FmsCloudFileTagListReq) !FmsCloudFileTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	mut count := sql db {
		select count from FmsCloudFileTag where del_flag == 0
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
		dynamic select from FmsCloudFileTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }
	mut datalist := []FmsCloudFileTagData{}
	for row in result {
		datalist << FmsCloudFileTagData{
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
	return FmsCloudFileTagListResp{
		total: count
		data:  datalist
	}
}
