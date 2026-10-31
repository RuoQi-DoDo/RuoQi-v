module route

import json2
import veb
import model { Context }

// API_VERSION mirrors backend/v.mod. Keeping it in the binary makes runtime
// documentation independent of whether v.mod is copied into a container.
const api_version = '0.5.0'

// build_openapi_document builds the OpenAPI document from registered routes.
pub fn (app &AliasApp) build_openapi_document() !veb.OpenApiDocument {
	mut controller_security := app.openapi_controller_security.clone()
	// Root routes are public; secured controllers inherit the document default.
	controller_security[typeof(AliasApp{}).name] = []map[string][]string{}
	mut doc := veb.new_openapi(
		title:                 'RuoQi-v API'
		description:           '本服务后端接口。路径由当前运行的路由表实时生成；业务失败时仍返回状态码 200，并通过非零业务码表示错误。'
		version:               api_version
		default_errors:        false
		security_errors:       false
		controller_security:   controller_security
		response_descriptions: {
			'200': '业务响应。即使业务处理失败，状态码也为 200，并通过非零业务码表示错误。'
		}
		security_schemes:      openapi_security_schemes()
		security:              openapi_secured_security()
	)!
	doc.add_app[AliasApp, Context](app)!
	// Validate operation IDs and security references during startup/export, not
	// on the first request to /openapi.json.
	_ = doc.json(false)!
	return doc
}

fn openapi_security_schemes() map[string]json2.Any {
	bearer := map[string]json2.Any{
		'type':         'http'
		'scheme':       'bearer'
		'bearerFormat': 'JWT'
		'description':  '从身份认证接口获取的访问令牌。'
	}
	access_key := map[string]json2.Any{
		'type':        'apiKey'
		'in':          'header'
		'name':        'X-Access-Key'
		'description': '访问密钥认证：访问密钥标识。需与时间戳和签名请求头共同使用。'
	}
	timestamp := map[string]json2.Any{
		'type':        'apiKey'
		'in':          'header'
		'name':        'X-Timestamp'
		'description': '访问密钥认证：请求时间戳，单位为秒。'
	}
	signature := map[string]json2.Any{
		'type':        'apiKey'
		'in':          'header'
		'name':        'X-Signature'
		'description': '访问密钥认证：请求签名。对请求方法、请求路径、请求体摘要和时间戳依次拼接后，使用密钥计算消息认证码并进行编码。'
	}
	return {
		'bearerAuth':    bearer
		'accessKeyAuth': access_key
		'timestampAuth': timestamp
		'signatureAuth': signature
	}
}

fn openapi_secured_security() []map[string][]string {
	return [
		{
			'bearerAuth': []string{}
		},
		{
			'accessKeyAuth': []string{}
			'timestampAuth': []string{}
			'signatureAuth': []string{}
		},
	]
}

// setup_openapi_document builds and pins the document after conditional routes
// have been registered by the application composition root.
pub fn (mut app AliasApp) setup_openapi_document() ! {
	app.openapi_document = app.build_openapi_document()!
	app.openapi_ready = true
}
