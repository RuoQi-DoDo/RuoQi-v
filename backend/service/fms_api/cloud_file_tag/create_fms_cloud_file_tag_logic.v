module cloud_file_tag

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &CloudFileTag) create_fms_cloud_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateFmsCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_fms_cloud_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

pub fn create_fms_cloud_file_tag_usecase(mut ctx Context, req CreateFmsCloudFileTagReq) !dto.MsgResp {
	create_fms_cloud_file_tag_domain(&req)!
	return create_fms_cloud_file_tag_repo(mut ctx, req)
}

fn create_fms_cloud_file_tag_domain(req &CreateFmsCloudFileTagReq) ! {
	if req.name == '' {
		return error('tag name is required')
	}
	if req.status == 0 {
		return error('status is required')
	}
}

pub struct CreateFmsCloudFileTagReq {
	name   string  @[json: 'name'; description: '名称']
	remark ?string @[json: 'remark'; description: '备注']
	status u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
}

fn create_fms_cloud_file_tag_repo(mut ctx Context, req CreateFmsCloudFileTagReq) !dto.MsgResp {
	time_now := time.now()
	tag := FmsCloudFileTag{
		id:         rand.uuid_v7()
		name:       req.name
		remark:     req.remark
		status:     req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert tag into FmsCloudFileTag
	} or { return error('Failed to create FmsCloudFileTag: ${err}') }
	return dto.MsgResp{
		msg: 'FmsCloudFileTag created successfully'
	}
}
