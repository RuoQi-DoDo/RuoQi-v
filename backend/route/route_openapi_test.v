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

fn test_runtime_openapi_uses_registered_routes_and_typed_contracts() {
	mut app := &AliasApp{}
	mut ctx := &Context{
		dbpool: unsafe { nil }
		config: unsafe { nil }
		locale: unsafe { nil }
	}
	app.setup_conditional_routes(mut ctx)
	app.setup_openapi_document()!

	raw := json2.decode[json2.Any](app.openapi_document.json(false)!)!
	assert openapi_test_at(raw, 'openapi').str() == '3.0.3'
	assert openapi_test_at(raw, 'info', 'title').str() == 'RuoQi-v API'

	currency_create := openapi_test_at(raw, 'paths', '/base/currency/create', 'post')
	assert openapi_test_at(currency_create, 'tags').as_array().map(it.str()) == [
		'currency.Currency',
	]
	assert openapi_test_at(currency_create, 'requestBody', 'content', 'application/json',
		'schema', '\$ref').str().ends_with('currency.CreateCurrencyReq')
	assert openapi_test_at(raw, 'components', 'schemas', 'currency.CreateCurrencyReq',
		'properties', 'currencyCode', 'description').str() == 'ISO 货币代码，例如 CNY'
	assert openapi_test_at(currency_create, 'security').as_array().len == 0
	assert openapi_test_at(currency_create, 'responses').as_map().keys() == ['200']
	assert openapi_test_at(currency_create, 'responses', '200', 'content', 'application/json',
		'schema', 'oneOf').as_array().len == 2

	user_create := openapi_test_at(raw, 'paths', '/iam/user/create_user', 'post')
	assert openapi_test_at(user_create, 'tags').as_array().map(it.str()) == ['user.User']
	assert openapi_test_at(user_create, 'security').as_array().len == 2
	assert 'bearerAuth' in openapi_test_at(raw, 'components', 'securitySchemes').as_map()
	assert 'accessKeyAuth' in openapi_test_at(raw, 'components', 'securitySchemes').as_map()

	grouped_tags := {
		'/fms/cloudfile/create':     'cloud_file.CloudFile'
		'/fms/cloudtag/create':      'cloud_file_tag.CloudFileTag'
		'/fms/cloudfile_tag/create': 'cloud_file_join_tag.CloudFileJoinTag'
		'/fms/file/create':          'file.File'
		'/fms/tag/create':           'file_tag.FileTag'
		'/fms/file_tag/create':      'file_join_tag.FileJoinTag'
		'/fms/provider/create':      'storage_provider.StorageProvider'
		'/pay/order/create':         'order.Order'
		'/pay/extension/create':     'order_extension.OrderExtension'
		'/pay/refund/create':        'refund.Refund'
		'/pay/demo/create':          'demo_order.DemoOrder'
	}
	for path, expected_tag in grouped_tags {
		operation := openapi_test_at(raw, 'paths', path, 'post')
		assert openapi_test_at(operation, 'tags').as_array().map(it.str()) == [expected_tag]
	}

	// The /openapi.json endpoint is itself captured from the dispatcher.
	assert '/static/openapi.json' in openapi_test_at(raw, 'paths').as_map()
	assert openapi_test_at(raw, 'paths', '/static/openapi.json', 'get',
		'tags').as_array().map(it.str()) == ['route.AliasApp']

	for route in veb.route_info[AliasApp, Context](app)! {
		for method in route.methods {
			operation := openapi_test_at(raw, 'paths', route.path, method.str().to_lower())
			tags := openapi_test_at(operation, 'tags').as_array()
			assert tags.len == 1
			assert tags[0].str() == route.controller
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
	served := json2.decode[json2.Any](response.res.body)!
	assert openapi_test_at(served, 'openapi').str() == '3.0.3'

	not_found := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/sys_api/admin/'
	})!
	assert not_found.res.status() == .not_found
	assert not_found.res.body.contains('短链接不存在')

	forbidden := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/static/403'
	})!
	assert forbidden.res.status() == .forbidden

	internal_error := veb.render_request[AliasApp, Context](mut app, http.Request{
		url: '/static/500'
	})!
	assert internal_error.res.status() == .internal_server_error
}
