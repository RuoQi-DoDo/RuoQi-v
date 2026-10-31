module route

import json2
import net.http
import veb
import dto
import model { Context }
import service.base_api.currency {
	CreateCurrencyReq,
	CurrencyListReq,
	CurrencyListResp,
	UpdateCurrencyReq,
}
import service.iam_service.iam_api.apikey {
	CreateApiKeyReq,
	CreateApiKeyResp,
}
import service.iam_service.iam_api.authentication {
	GetCaptchaResp,
	LoginByAccountReq,
	LoginByAccountResp,
}
import service.iam_service.iam_api.user { CreateUserReq }
import service.platform_service.platform_api { CreateApiReq }

// API_VERSION mirrors backend/v.mod. Keeping it in the binary makes runtime
// documentation independent of whether v.mod is copied into a container.
const api_version = '0.5.0'

// build_openapi_document uses veb's route metadata and typed schema helpers,
// adding only the business response envelope that OpenAPI 3.0 cannot infer.
pub fn (app &AliasApp) build_openapi_document() !veb.OpenApiDocument {
	mut controller_security := app.openapi_controller_security.clone()
	// Root routes are public; secured controllers inherit the document default.
	controller_security[typeof(AliasApp{}).name] = []map[string][]string{}
	mut doc := veb.new_openapi(
		title:                 'RuoQi-v API'
		description:           'RuoQi backend API. Paths are generated from the live veb dispatcher; business failures use HTTP 200 with a non-zero response code.'
		version:               api_version
		default_errors:        false
		security_errors:       false
		controller_security:   controller_security
		response_descriptions: {
			'200': 'Business response. HTTP 200 is also used when code is non-zero.'
		}
		security_schemes:      {
			'bearerAuth':    json2.Any({
				'type':         json2.Any('http')
				'scheme':       json2.Any('bearer')
				'bearerFormat': json2.Any('JWT')
				'description':  json2.Any('JWT obtained from an IAM authentication endpoint.')
			})
			'accessKeyAuth': json2.Any({
				'type':        json2.Any('apiKey')
				'in':          json2.Any('header')
				'name':        json2.Any('X-Access-Key')
				'description': json2.Any('AK/SK authentication: access key ID. Use together with X-Timestamp and X-Signature.')
			})
			'timestampAuth': json2.Any({
				'type':        json2.Any('apiKey')
				'in':          json2.Any('header')
				'name':        json2.Any('X-Timestamp')
				'description': json2.Any('AK/SK authentication: Unix timestamp in seconds.')
			})
			'signatureAuth': json2.Any({
				'type':        json2.Any('apiKey')
				'in':          json2.Any('header')
				'name':        json2.Any('X-Signature')
				'description': json2.Any('AK/SK authentication: Base64(HMAC-SHA256(SK, METHOD + newline + PATH + newline + SHA256_HEX(BODY) + newline + TIMESTAMP)).')
			})
		}
		security:              openapi_secured_security()
	)!
	doc.custom_schema('ApiSuccessResponse', openapi_success_component())
	doc.custom_schema('ApiErrorResponse', openapi_error_component())
	doc.add_app[AliasApp, Context](app)!
	add_typed_endpoints(mut doc)!
	// Validate operation IDs and security references during startup/export, not
	// on the first request to /openapi.json.
	_ = doc.json(false)!
	return doc
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

fn add_typed_endpoints(mut doc veb.OpenApiDocument) ! {
	// Base master data: public CRUD examples.
	doc.request[CreateCurrencyReq]('/base/currency/create', .post)!
	add_typed_api_response[dto.MsgResp](mut doc, '/base/currency/create', .post)!
	doc.request[CurrencyListReq]('/base/currency/all', .get, query: false)!
	add_typed_api_response[CurrencyListResp](mut doc, '/base/currency/all', .get)!
	doc.request[UpdateCurrencyReq]('/base/currency/update', .post)!
	add_typed_api_response[dto.MsgResp](mut doc, '/base/currency/update', .post)!
	doc.request[dto.DeleteIdsReq]('/base/currency/delete', .post)!
	add_typed_api_response[dto.MsgResp](mut doc, '/base/currency/delete', .post)!

	// Public IAM authentication endpoints.
	doc.request[LoginByAccountReq]('/iam/auth/login_by_account', .post)!
	add_typed_api_response[LoginByAccountResp](mut doc, '/iam/auth/login_by_account', .post)!
	add_typed_api_response[GetCaptchaResp](mut doc, '/iam/auth/captcha', .get)!
	add_typed_api_response[GetCaptchaResp](mut doc, '/iam/auth/captcha', .post)!

	// Secured IAM/platform endpoints demonstrate the same official API under
	// workspace RBAC and AK/SK scopes.
	doc.request[CreateApiKeyReq]('/iam/apikey/create', .post)!
	add_typed_api_response[CreateApiKeyResp](mut doc, '/iam/apikey/create', .post)!
	doc.request[CreateUserReq]('/iam/user/create_user', .post)!
	add_typed_api_response[dto.MsgResp](mut doc, '/iam/user/create_user', .post)!
	doc.request[CreateApiReq]('/platform/api/create_api', .post)!
	add_typed_api_response[dto.CreatedResp](mut doc, '/platform/api/create_api', .post)!
}

fn add_typed_api_response[T](mut doc veb.OpenApiDocument, path string, method http.Method) ! {
	data_schema := doc.schema[T]()
	success_schema := openapi_typed_success_schema(data_schema)
	error_schema := veb.OpenApiSchema({
		'$ref': json2.Any('#/components/schemas/ApiErrorResponse')
	})
	doc.raw_response(path, method, 200,
		api_response(openapi_api_response_schema(success_schema, error_schema)))!
}

fn api_response(schema veb.OpenApiSchema) map[string]json2.Any {
	return {
		'description': json2.Any('Business response. HTTP 200 is also used when code is non-zero.')
		'content':     json2.Any({
			'application/json': json2.Any({
				'schema': json2.Any(schema)
			})
		})
	}
}

fn openapi_api_response_schema(success_schema veb.OpenApiSchema, error_schema veb.OpenApiSchema) veb.OpenApiSchema {
	return {
		'oneOf': json2.Any([
			json2.Any(success_schema),
			json2.Any(error_schema),
		])
	}
}

fn openapi_success_component() veb.OpenApiSchema {
	return {
		'type':        json2.Any('object')
		'description': json2.Any('Standard successful business response.')
		'required':    json2.Any([json2.Any('code'), json2.Any('request_id'), json2.Any('data'),
			json2.Any('msg')])
		'properties':  json2.Any({
			'code':       json2.Any({
				'type':        json2.Any('integer')
				'description': json2.Any('Business status. 0 means success.')
				'example':     json2.Any(0)
			})
			'request_id': json2.Any({
				'type':        json2.Any('string')
				'description': json2.Any('Request correlation ID.')
			})
			'data':       json2.Any({
				'description': json2.Any('Endpoint-specific success payload.')
			})
			'msg':        json2.Any({
				'type':        json2.Any('string')
				'description': json2.Any('Human-readable result message.')
				'example':     json2.Any('success')
			})
		})
	}
}

fn openapi_error_component() veb.OpenApiSchema {
	return {
		'type':        json2.Any('object')
		'description': json2.Any('Standard business error response. Failures normally use HTTP 200 with a non-zero code.')
		'required':    json2.Any([json2.Any('code'), json2.Any('request_id'), json2.Any('msg')])
		'properties':  json2.Any({
			'code':       json2.Any({
				'type':        json2.Any('integer')
				'description': json2.Any('Stable business error code. Non-zero means failure.')
				'example':     json2.Any(100001)
			})
			'request_id': json2.Any({
				'type':        json2.Any('string')
				'description': json2.Any('Request correlation ID.')
			})
			'msg':        json2.Any({
				'type':        json2.Any('string')
				'description': json2.Any('Human-readable error message.')
				'example':     json2.Any('Invalid request')
			})
		})
	}
}

fn openapi_typed_success_schema(data_schema veb.OpenApiSchema) veb.OpenApiSchema {
	return {
		'type':        json2.Any('object')
		'description': json2.Any('Successful business response (code = 0).')
		'required':    json2.Any([json2.Any('code'), json2.Any('request_id'), json2.Any('data'),
			json2.Any('msg')])
		'properties':  json2.Any({
			'code':       json2.Any({
				'type':    json2.Any('integer')
				'example': json2.Any(0)
			})
			'request_id': json2.Any({
				'type':        json2.Any('string')
				'description': json2.Any('Request correlation ID.')
			})
			'data':       json2.Any(data_schema)
			'msg':        json2.Any({
				'type':    json2.Any('string')
				'example': json2.Any('success')
			})
		})
	}
}
