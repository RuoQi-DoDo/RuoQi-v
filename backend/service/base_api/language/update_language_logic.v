module language

import dto
import veb
import log
import time
import json2 as json
import model.schema_base { BaseLanguage }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Language) update_language_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateLanguageReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_language_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_language_usecase(mut ctx Context, req UpdateLanguageReq) !dto.MsgResp {
	// Domain 校验
	update_language_domain(&req)!

	// Repository 更新
	return update_language_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_language_domain(req &UpdateLanguageReq) ! {
	if req.id == '' {
		return error('language id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateLanguageReq {
	id                       string  @[json: 'id'; description: '唯一标识']
	language_self_proclaimed ?string @[json: 'languageSelfProclaimed'; description: '语言自称']
	language_code            ?string @[json: 'languageCode'; description: '语言代码']
	two_letter_code          ?string @[json: 'twoLetterCode'; description: '两位字母代码']
	three_letter_code        ?string @[json: 'threeLetterCode'; description: '三位字母代码']
	utf8_encoding            ?string @[json: 'utf8Encoding'; description: 'UTF-8 编码']
	sort                     ?int    @[json: 'sort'; description: '排序值，数字越小越靠前']
	status                   ?u8     @[json: 'status'; description: '状态：0 禁用，1 启用']
	is_basic                 ?u8     @[json: 'isBasic'; description: '是否为基础数据']
}

// ═══ Repository ═══
fn update_language_repo(mut ctx Context, req UpdateLanguageReq) !dto.MsgResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.language_self_proclaimed {
			language_self_proclaimed == v
		},
		if v := req.language_code {
			language_code == v
		},
		if v := req.two_letter_code {
			two_letter_code == v
		},
		if v := req.three_letter_code {
			three_letter_code == v
		},
		if v := req.utf8_encoding {
			utf8_encoding == v
		},
		if v := req.sort {
			sort == v
		},
		if v := req.status {
			status == v
		},
		if v := req.is_basic {
			is_basic == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseLanguage set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return dto.MsgResp{
		msg: 'language updated successfully'
	}
}
