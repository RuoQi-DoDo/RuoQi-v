module language

import log
import time
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseLanguage }

// ═══ Tool ═══
pub fn find_language_all_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_language_find_all'
		title:        'List languages'
		description:  'List base languages with optional filters and pagination.'
		input_schema: '{"type":"object","properties":{"page":{"type":"integer","minimum":1,"description":"Page number, defaults to 1"},"pageSize":{"type":"integer","minimum":1,"description":"Page size, defaults to 20"},"languageSelfProclaimed":{"type":"string"},"languageCode":{"type":"string"},"twoLetterCode":{"type":"string"},"threeLetterCode":{"type":"string"},"utf8Encoding":{"type":"string"},"isBasic":{"type":"integer"},"status":{"type":"array","items":{"type":"integer"}}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  true
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[LanguageListReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := find_language_all_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn find_language_all_usecase(pool &dbpool.DatabasePoolable, req LanguageListReq) !LanguageListResp {
	find_language_all_domain()
	return find_language_all_repo(pool, req)
}

// ═══ Domain ═══
fn find_language_all_domain() {
}

// ═══ DTO ═══
pub struct LanguageListReq {
	page                     int    @[json: 'page']
	page_size                int    @[json: 'pageSize']
	language_self_proclaimed string @[json: 'languageSelfProclaimed']
	language_code            string @[json: 'languageCode']
	two_letter_code          string @[json: 'twoLetterCode']
	three_letter_code        string @[json: 'threeLetterCode']
	utf8_encoding            string @[json: 'utf8Encoding']
	status                   []u8   @[json: 'status']
	is_basic                 u8     @[json: 'isBasic']
}

pub struct LanguageData {
	id                       string  @[json: 'id']
	language_self_proclaimed string  @[json: 'languageSelfProclaimed']
	language_code            string  @[json: 'languageCode']
	two_letter_code          string  @[json: 'twoLetterCode']
	three_letter_code        string  @[json: 'threeLetterCode']
	utf8_encoding            string  @[json: 'utf8Encoding']
	sort                     ?int    @[json: 'sort']
	status                   u8      @[json: 'status']
	is_basic                 u8      @[json: 'isBasic']
	updater_id               ?string @[json: 'updaterId']
	creator_id               ?string @[json: 'creatorId']
	created_at               string  @[json: 'createdAt']
	updated_at               string  @[json: 'updatedAt']
	deleted_at               string  @[json: 'deletedAt']
}

pub struct LanguageListResp {
	total int
	data  []LanguageData
}

// ═══ Repository ═══
fn find_language_all_repo(pool &dbpool.DatabasePoolable, req LanguageListReq) !LanguageListResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	page := if req.page <= 0 { 1 } else { req.page }
	page_size := if req.page_size <= 0 { 20 } else { req.page_size }

	// 总数统计
	mut count := sql db {
		select count from BaseLanguage
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (page - 1) * page_size
	// vfmt off
	where_expr := {
			if req.language_self_proclaimed != '' {language_self_proclaimed == req.language_self_proclaimed},
			if req.language_code != '' {language_code == req.language_code},
			if req.two_letter_code != '' {two_letter_code == req.two_letter_code},
			if req.three_letter_code != '' {three_letter_code == req.three_letter_code},
			if req.utf8_encoding != '' {utf8_encoding == req.utf8_encoding},
			if req.is_basic != 0 {is_basic == req.is_basic},
			if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from BaseLanguage where where_expr order by sort limit page_size offset offset_num
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
