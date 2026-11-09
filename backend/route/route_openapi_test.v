module route

import json2
import net.http
import veb
import model { Context }
import service.fms_api.cloud_file { FmsCloudFileData }
import service.pay_api.demo_order { PayDemoOrderData }

fn openapi_test_at(value json2.Any, keys ...string) json2.Any {
	mut current := value
	for key in keys {
		current = current.as_map()[key] or { return json2.Any(json2.Null{}) }
	}
	return current
}

fn test_nested_data_schemas_include_field_descriptions() {
	mut doc := veb.new_openapi(title: 'Nested schema test')!
	_ = doc.schema[PayDemoOrderData]()
	_ = doc.schema[FmsCloudFileData]()

	raw := json2.decode[json2.Any](doc.json(false)!)!
	assert openapi_test_at(raw, 'components', 'schemas', 'demo_order.PayDemoOrderData',
		'properties', 'spuName', 'description').str() == '商品 SPU 名称'
	assert openapi_test_at(raw, 'components', 'schemas', 'cloud_file.FmsCloudFileData',
		'properties', 'url', 'description').str() == '云文件资源地址'
}

fn test_runtime_openapi_uses_registered_routes() {
	mut app := &AliasApp{}
	mut ctx := &Context{
		dbpool: unsafe { nil }
		config: unsafe { nil }
		locale: unsafe { nil }
	}
	app.setup_conditional_routes(mut ctx)
	app.setup_openapi_document()!

	raw := json2.decode[json2.Any](app.openapi_document.json(false)!)!
	assert openapi_test_at(raw, 'openapi').str() == '3.2.0'
	assert openapi_test_at(raw, 'info', 'title').str() == 'RuoQi-v API'

	currency_create := openapi_test_at(raw, 'paths', '/base/currency/create', 'post')
	assert openapi_test_at(currency_create, 'tags').as_array().map(it.str()) == [
		'base.currency',
	]
	assert openapi_test_at(currency_create, 'description').str() == '创建基础货币，写入 ISO 代码、名称、汇率和启用状态。'
	assert openapi_test_at(currency_create, 'security').as_array().len == 0
	assert openapi_test_at(currency_create, 'responses').as_map().keys() == ['200']
	assert openapi_test_at(currency_create, 'responses', '200', 'description').str() == '业务响应。即使业务处理失败，状态码也为 200，并通过非零业务码表示错误。'

	user_create := openapi_test_at(raw, 'paths', '/iam/user/create_user', 'post')
	assert openapi_test_at(user_create, 'tags').as_array().map(it.str()) == ['iam.user']
	assert openapi_test_at(user_create, 'description').str() == '创建用户账号。'
	assert openapi_test_at(user_create, 'security').as_array().len == 2
	assert 'bearerAuth' in openapi_test_at(raw, 'components', 'securitySchemes').as_map()
	assert 'accessKeyAuth' in openapi_test_at(raw, 'components', 'securitySchemes').as_map()

	grouped_tags := {
		'/fms/cloudfile/create':     'fms.cloud_file'
		'/fms/cloudtag/create':      'fms.cloud_file_tag'
		'/fms/cloudfile_tag/create': 'fms.cloud_file_join_tag'
		'/fms/file/create':          'fms.file'
		'/fms/tag/create':           'fms.file_tag'
		'/fms/file_tag/create':      'fms.file_join_tag'
		'/fms/provider/create':      'fms.storage_provider'
		'/pay/order/create':         'pay.order'
		'/pay/extension/create':     'pay.order_extension'
		'/pay/refund/create':        'pay.refund'
		'/pay/demo/create':          'pay.demo_order'
	}
	for path, expected_tag in grouped_tags {
		operation := openapi_test_at(raw, 'paths', path, 'post')
		assert openapi_test_at(operation, 'tags').as_array().map(it.str()) == [expected_tag]
	}

	tags := openapi_test_at(raw, 'tags').as_array()
	tag_names := tags.map(openapi_test_at(it, 'name').str())
	assert tag_names.index('base') < tag_names.index('base.currency')
	assert tag_names.index('iam') < tag_names.index('iam.user')
	assert tag_names.index('fms') < tag_names.index('fms.file')
	currency_tag := tags.filter(openapi_test_at(it, 'name').str() == 'base.currency')[0]
	assert openapi_test_at(currency_tag, 'parent').str() == 'base'
	assert openapi_test_at(currency_tag, 'summary').str() == '货币'
	assert openapi_test_at(currency_tag, 'kind').str() == 'nav'

	mut controller_tags := map[string][]string{}
	for definition in openapi_tags() {
		for controller in definition.controllers {
			controller_tags[controller] << definition.name
		}
	}

	// The /openapi.json endpoint is itself captured from the dispatcher.
	assert '/static/openapi.json' in openapi_test_at(raw, 'paths').as_map()
	assert openapi_test_at(raw, 'paths', '/static/openapi.json', 'get',
		'tags').as_array().map(it.str()) == ['system.docs']

	for route in veb.route_info[AliasApp, Context](app)! {
		for method in route.methods {
			operation := openapi_test_at(raw, 'paths', route.path, method.str().to_lower())
			operation_tags := openapi_test_at(operation, 'tags').as_array()
			assert operation_tags.len == 1
			assert route.controller in controller_tags, 'missing OpenAPI tag for controller ${route.controller}'
			assert operation_tags.map(it.str()) == controller_tags[route.controller]
			assert openapi_test_at(operation, 'description').str() != ''
			assert openapi_test_at(operation, 'security').as_array().len in [0, 2]
		}
	}

	for viewer_url in ['/static/rapidoc', '/static/redoc', '/static/sleapidoc', '/static/scalar'] {
		viewer_response := veb.render_request[AliasApp, Context](mut app, http.Request{
			url: viewer_url
		})!
		assert viewer_response.return_type == .file
	}
	response := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/static/openapi.json'
	})!
	assert response.res.header.get(.cache_control) or { '' } == 'no-store'
	served := json2.decode[json2.Any](response.res.body)!
	assert openapi_test_at(served, 'openapi').str() == '3.2.0'

	not_found := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/sys_api/admin/'
	})!
	assert not_found.res.status() == .not_found
	assert not_found.res.body.contains('页面不存在')

	forbidden := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/static/403'
	})!
	assert forbidden.res.status() == .forbidden

	internal_error := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/static/500'
	})!
	assert internal_error.res.status() == .internal_server_error
}
