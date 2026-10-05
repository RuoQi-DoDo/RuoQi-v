module language

import log
import time
import rand
import json2 as json
import mcp
import adapter.dbpool
import model.schema_base { BaseLanguage }

// ═══ Tool ═══
pub fn create_language_tool(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	server.add_tool(mcp.Tool{
		name:         'base_language_create'
		title:        'Create language'
		description:  'Create a new base language record.'
		input_schema: '{"type":"object","required":["languageSelfProclaimed","languageCode","twoLetterCode","threeLetterCode","utf8Encoding","status"],"properties":{"languageSelfProclaimed":{"type":"string"},"languageCode":{"type":"string"},"twoLetterCode":{"type":"string"},"threeLetterCode":{"type":"string"},"utf8Encoding":{"type":"string"},"sort":{"type":"integer"},"status":{"type":"integer"},"isBasic":{"type":"integer"}}}'
		annotations:  mcp.ToolAnnotations{
			read_only_hint:  false
			idempotent_hint: false
			open_world_hint: false
		}
	}, fn [pool] (_ mcp.Context, arguments string) !mcp.ToolResult {
		req := json.decode[CreateLanguageReq](arguments) or {
			return error('invalid arguments: ${err.msg()}')
		}
		result := create_language_usecase(pool, req) or { return error('${err}') }
		return mcp.tool_text_result(json.encode(result))
	})!
}

// ═══ Use Case ═══
pub fn create_language_usecase(pool &dbpool.DatabasePoolable, req CreateLanguageReq) !CreateLanguageResp {
	create_language_domain(req)!
	return create_language_repo(pool, req)
}

// ═══ Domain ═══
fn create_language_domain(req CreateLanguageReq) ! {
	if req.language_code == '' {
		return error('language_code is required')
	}
	if req.language_self_proclaimed == '' {
		return error('language_self_proclaimed is required')
	}
}

// ═══ DTO ═══
pub struct CreateLanguageReq {
	language_self_proclaimed string @[json: 'languageSelfProclaimed']
	language_code            string @[json: 'languageCode']
	two_letter_code          string @[json: 'twoLetterCode']
	three_letter_code        string @[json: 'threeLetterCode']
	utf8_encoding            string @[json: 'utf8Encoding']
	sort                     ?int   @[json: 'sort']
	status                   u8     @[json: 'status']
	is_basic                 u8     @[json: 'isBasic']
}

pub struct CreateLanguageResp {
	id  string @[json: 'id']
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_language_repo(pool &dbpool.DatabasePoolable, req CreateLanguageReq) !CreateLanguageResp {
	time_now := time.now()
	new_id := rand.uuid_v7()
	base_language := BaseLanguage{
		id:                       new_id
		language_self_proclaimed: req.language_self_proclaimed
		language_code:            req.language_code
		two_letter_code:          req.two_letter_code
		three_letter_code:        req.three_letter_code
		utf8_encoding:            req.utf8_encoding
		sort:                     req.sort
		status:                   req.status
		is_basic:                 req.is_basic
		created_at:               time_now
		updated_at:               time_now
	}

	db, conn := pool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_language into BaseLanguage
	} or { return error('Failed to create Language: ${err}') }

	return CreateLanguageResp{
		id:  new_id
		msg: 'Language created successfully'
	}
}
