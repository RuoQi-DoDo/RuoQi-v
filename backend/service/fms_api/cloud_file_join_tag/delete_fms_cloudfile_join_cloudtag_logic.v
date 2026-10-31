module cloud_file_join_tag

import dto
import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFileCloudFileTag }
import common.api
import model { Context }

@['/delete'; post]
pub fn (app &CloudFileJoinTag) delete_fms_cloudfile_join_cloudtag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteFmsCloudFileCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_fms_cloudfile_join_cloudtag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn delete_fms_cloudfile_join_cloudtag_usecase(mut ctx Context, req DeleteFmsCloudFileCloudFileTagReq) !dto.MsgResp {
	delete_fms_cloudfile_join_cloudtag_domain(&req)!
	return delete_fms_cloudfile_join_cloudtag_repo(mut ctx, req)
}

fn delete_fms_cloudfile_join_cloudtag_domain(req &DeleteFmsCloudFileCloudFileTagReq) ! {
	if req.cloud_file_tag_id == '' || req.cloud_file_id == '' {
		return error('both ids are required')
	}
}

pub struct DeleteFmsCloudFileCloudFileTagReq {
	cloud_file_tag_id string @[json: 'cloudFileTagId'; description: '云文件标签 ID']
	cloud_file_id     string @[json: 'cloudFileId'; description: '云文件 ID']
}

fn delete_fms_cloudfile_join_cloudtag_repo(mut ctx Context, req DeleteFmsCloudFileCloudFileTagReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from FmsCloudFileCloudFileTag where cloud_file_tag_id == req.cloud_file_tag_id
		&& cloud_file_id == req.cloud_file_id
	} or { return error('Failed: ${err}') }
	return dto.MsgResp{
		msg: 'Cloud file-tag link deleted successfully'
	}
}
