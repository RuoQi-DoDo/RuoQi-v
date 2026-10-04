module language

import log
import time
import json2 as json
import common.mcp
import adapter.dbpool
import model.schema_base { BaseLanguage }

// ═══ Tool ═══
pub fn update_language_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_language_update'
		title:        'Update language'
		description:  'Update an existing base language record by id.'
		input_schema: '{"type":"object","required":["id"],"properties":{"id":{"type":"string"},"languageSelfProclaimed":{"type":"string"},"languageCode":{"type":"string"},"twoLetterCode":{"type":"string"},"threeLetterCode":{"type":"string"},"utf8Encoding":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"isBasic":{"type":"integer"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: true
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[UpdateLanguageReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := update_language_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn update_language_usecase(pool &dbpool.DatabasePoolable, req UpdateLanguageReq) !UpdateLanguageResp {
	update_language_domain(req)!
	return update_language_repo(pool, req)
}

// ═══ Domain ═══
fn update_language_domain(req UpdateLanguageReq) ! {
	if req.id == '' {
		return error('language id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateLanguageReq {
	id                       string  @[json: 'id']
	language_self_proclaimed ?string @[json: 'languageSelfProclaimed']
	language_code            ?string @[json: 'languageCode']
	two_letter_code          ?string @[json: 'twoLetterCode']
	three_letter_code        ?string @[json: 'threeLetterCode']
	utf8_encoding            ?string @[json: 'utf8Encoding']
	sort                     ?int    @[json: 'sort']
	status                   ?u8     @[json: 'status']
	is_basic                 ?u8     @[json: 'isBasic']
}

pub struct UpdateLanguageResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_language_repo(pool &dbpool.DatabasePoolable, req UpdateLanguageReq) !UpdateLanguageResp {
	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

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
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update BaseLanguage set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateLanguageResp{
		msg: 'Language updated successfully'
	}
}
