module storage_provider

import dto
import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/create'; post]
pub fn (app &StorageProvider) create_fms_storage_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateFmsStorageProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := create_fms_storage_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn create_fms_storage_provider_usecase(mut ctx Context, req CreateFmsStorageProviderReq) !dto.MsgResp {
	create_fms_storage_provider_domain(&req)!
	return create_fms_storage_provider_repo(mut ctx, req)
}

fn create_fms_storage_provider_domain(req &CreateFmsStorageProviderReq) ! {
	if req.name == '' {
		return error('provider name is required')
	}
	if req.bucket == '' {
		return error('bucket is required')
	}
	if req.secret_id == '' {
		return error('secret id is required')
	}
	if req.secret_key == '' {
		return error('secret key is required')
	}
	if req.endpoint == '' {
		return error('endpoint is required')
	}
	if req.region == '' {
		return error('region is required')
	}
}

pub struct CreateFmsStorageProviderReq {
	name       string  @[json: 'name'; description: '名称']
	bucket     string  @[json: 'bucket'; description: '存储桶名称']
	secret_id  string  @[json: 'secretId'; description: '密钥 ID']
	secret_key string  @[json: 'secretKey'; description: '密钥 Secret']
	endpoint   string  @[json: 'endpoint'; description: '服务地址']
	folder     ?string @[json: 'folder'; description: '目标目录']
	region     string  @[json: 'region'; description: '地区']
	is_default u8      @[json: 'isDefault'; description: '是否为默认项']
	use_cdn    u8      @[json: 'useCdn'; description: '是否使用 CDN']
	cdn_url    ?string @[json: 'cdnUrl'; description: 'CDN 地址']
	status     u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
}

fn create_fms_storage_provider_repo(mut ctx Context, req CreateFmsStorageProviderReq) !dto.MsgResp {
	time_now := time.now()
	p := FmsStorageProvider{
		id:         rand.uuid_v7()
		name:       req.name
		bucket:     req.bucket
		secret_id:  req.secret_id
		secret_key: req.secret_key
		endpoint:   req.endpoint
		folder:     req.folder
		region:     req.region
		is_default: req.is_default
		use_cdn:    req.use_cdn
		cdn_url:    req.cdn_url
		status:     req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert p into FmsStorageProvider
	} or { return error('Failed to create FmsStorageProvider: ${err}') }
	return dto.MsgResp{
		msg: 'FmsStorageProvider created successfully'
	}
}
