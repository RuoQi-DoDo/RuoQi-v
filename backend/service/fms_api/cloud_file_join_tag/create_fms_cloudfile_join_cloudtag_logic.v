module cloud_file_join_tag

import dto
import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFileCloudFileTag }
import common.api
import model { Context }

@['/create'; post]
pub fn (app &CloudFileJoinTag) create_fms_cloudfile_join_cloudtag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateFmsCloudFileCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := create_fms_cloudfile_join_cloudtag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn create_fms_cloudfile_join_cloudtag_usecase(mut ctx Context, req CreateFmsCloudFileCloudFileTagReq) !dto.MsgResp {
	create_fms_cloudfile_join_cloudtag_domain(&req)!
	return create_fms_cloudfile_join_cloudtag_repo(mut ctx, req)
}

fn create_fms_cloudfile_join_cloudtag_domain(req &CreateFmsCloudFileCloudFileTagReq) ! {
	if req.cloud_file_tag_id == '' {
		return error('cloud file tag id is required')
	}
	if req.cloud_file_id == '' {
		return error('cloud file id is required')
	}
}

pub struct CreateFmsCloudFileCloudFileTagReq {
	cloud_file_tag_id string @[json: 'cloudFileTagId'; description: '云文件标签 ID']
	cloud_file_id     string @[json: 'cloudFileId'; description: '云文件 ID']
}

fn create_fms_cloudfile_join_cloudtag_repo(mut ctx Context, req CreateFmsCloudFileCloudFileTagReq) !dto.MsgResp {
	join := FmsCloudFileCloudFileTag{
		cloud_file_tag_id: req.cloud_file_tag_id
		cloud_file_id:     req.cloud_file_id
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	existing := sql db {
		select from FmsCloudFileCloudFileTag where cloud_file_tag_id == req.cloud_file_tag_id
		&& cloud_file_id == req.cloud_file_id limit 1
	} or { return error('Failed to check duplicate: ${err}') }
	if existing.len > 0 {
		return error('Link between cloud file and cloud tag already exists')
	}

	sql db {
		insert join into FmsCloudFileCloudFileTag
	} or { return error('Failed to create cloud file-tag link: ${err}') }
	return dto.MsgResp{
		msg: 'Cloud file-tag link created successfully'
	}
}
