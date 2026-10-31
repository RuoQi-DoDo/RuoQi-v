module language

import veb
import log
import time
import model.schema_base { BaseLanguage }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Language) find_language_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LanguageListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_language_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_language_all_usecase(mut ctx Context, req LanguageListReq) !LanguageListResp {
	find_language_all_domain()
	return find_language_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_language_all_domain() {
}

// ═══ DTO ═══
pub struct LanguageListReq {
	page                     int    @[json: 'page'; description: '页码，从 1 开始']
	page_size                int    @[json: 'pageSize'; description: '每页记录数']
	language_self_proclaimed string @[json: 'languageSelfProclaimed'; description: '语言自称']
	language_code            string @[json: 'languageCode'; description: '语言代码']
	two_letter_code          string @[json: 'twoLetterCode'; description: '两位字母代码']
	three_letter_code        string @[json: 'threeLetterCode'; description: '三位字母代码']
	utf8_encoding            string @[json: 'utf8Encoding'; description: 'UTF-8 编码']
	status                   []u8   @[json: 'status'; description: '状态：0 禁用，1 启用']
	is_basic                 u8     @[json: 'isBasic'; description: '是否为基础数据']
}

pub struct LanguageData {
	id                       string  @[json: 'id'; description: '唯一标识']
	language_self_proclaimed string  @[json: 'languageSelfProclaimed'; description: '语言自称']
	language_code            string  @[json: 'languageCode'; description: '语言代码']
	two_letter_code          string  @[json: 'twoLetterCode'; description: '两位语言代码']
	three_letter_code        string  @[json: 'threeLetterCode'; description: '三位语言代码']
	utf8_encoding            string  @[json: 'utf8Encoding'; description: 'UTF-8 编码名称']
	sort                     ?int    @[json: 'sort'; description: '排序值']
	status                   u8      @[json: 'status'; description: '状态：0 禁用，1 启用']
	is_basic                 u8      @[json: 'isBasic'; description: '是否基础语言：0 否，1 是']
	updater_id               ?string @[json: 'updaterId'; description: '更新者 ID']
	creator_id               ?string @[json: 'creatorId'; description: '创建者 ID']
	created_at               string  @[json: 'createdAt'; description: '创建时间']
	updated_at               string  @[json: 'updatedAt'; description: '更新时间']
	deleted_at               string  @[json: 'deletedAt'; description: '删除时间']
}

pub struct LanguageListResp {
	total int            @[description: '总记录数']
	data  []LanguageData @[description: '响应数据']
}

// ═══ Repository ═══
fn find_language_all_repo(mut ctx Context, req LanguageListReq) !LanguageListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseLanguage
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
				if req.language_self_proclaimed != '' {language_self_proclaimed == req.language_self_proclaimed},
				if req.language_code != '' {language_code == req.language_code},
				if req.two_letter_code != '' {two_letter_code == req.two_letter_code},
				if req.three_letter_code != '' {three_letter_code == req.three_letter_code},
				if req.utf8_encoding != '' {utf8_encoding == req.utf8_encoding},
				if req.is_basic.str() != '' {is_basic == req.is_basic}
		}
	// vfmt on
	mut result := sql db {
		dynamic select from BaseLanguage where where_expr order by sort limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []LanguageData{}
	for row in result {
		datalist << LanguageData{
			id:                       row.id
			language_self_proclaimed: row.language_self_proclaimed
			language_code:            row.language_code
			two_letter_code:          row.two_letter_code
			three_letter_code:        row.three_letter_code
			utf8_encoding:            row.utf8_encoding
			sort:                     row.sort
			status:                   row.status
			is_basic:                 row.is_basic
			updater_id:               row.updater_id
			creator_id:               row.creator_id
			created_at:               row.created_at.format_ss()
			updated_at:               row.updated_at.format_ss()
			deleted_at:               (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return LanguageListResp{
		total: count
		data:  datalist
	}
}
