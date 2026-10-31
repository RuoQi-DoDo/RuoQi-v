module cloud_file_tag

import dto
import veb
import log
import time
import json2 as json
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }

@['/update'; post]
pub fn (app &CloudFileTag) update_fms_cloud_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateFmsCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_fms_cloud_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn update_fms_cloud_file_tag_usecase(mut ctx Context, req UpdateFmsCloudFileTagReq) !dto.MsgResp {
	update_fms_cloud_file_tag_domain(&req)!
	return update_fms_cloud_file_tag_repo(mut ctx, req)
}

fn update_fms_cloud_file_tag_domain(req &UpdateFmsCloudFileTagReq) ! {
	if req.id == '' {
		return error('tag id is required')
	}
}

pub struct UpdateFmsCloudFileTagReq {
	id     string  @[json: 'id'; description: '唯一标识']
	name   ?string @[json: 'name'; description: '名称']
	remark ?string @[json: 'remark'; description: '备注']
	status ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
}

fn update_fms_cloud_file_tag_repo(mut ctx Context, req UpdateFmsCloudFileTagReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	existing := sql db {
		select from FmsCloudFileTag where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed to check existence: ${err}') }
	if existing.len == 0 {
		return error('FmsCloudFileTag with id ${req.id} not found')
	}

	// vfmt off
	up_expr := {
		if v := req.name {
			name == v
		},
		if v := req.remark {
			remark == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on
	sql db {
		dynamic update FmsCloudFileTag set up_expr where id == req.id && del_flag == 0
	} or { return error('Failed to update cloud file tag: ${err}') }
	return dto.MsgResp{
		msg: 'FmsCloudFileTag updated successfully'
	}
}
