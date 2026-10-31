module route

import veb
import log
import common.api
import model { Context }
import os

@['/get'; get]
pub fn (mut app AliasApp) get(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	dump(ctx.config)
	dump(ctx.config.web.port)
	return ctx.json(api.json_success(data: 'req success'))
}

@['/static/403'; get; post]
fn (mut app AliasApp) index_403(mut ctx Context) veb.Result {
	return ctx.forbidden()
}

@['/static/404'; get; post]
fn (mut app AliasApp) index_404(mut ctx Context) veb.Result {
	return ctx.not_found()
}

@['/static/500'; get; post]
fn (mut app AliasApp) index_500(mut ctx Context) veb.Result {
	return ctx.server_error('Internal Server Error')
}

@['/index'; get; post]
fn (mut app AliasApp) index(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'static/index.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>index Not Found</h1><p>index页面未找到</p>')
	}

	// 读取CSS文件并内联
	css_path := os.join_path(os.getwd(), 'static/styles.css')
	css_content := os.read_file(css_path) or { '' }

	// 将CSS内联到HTML中
	final_html := html_content.replace('</head>', '<style>${css_content}</style></head>')

	return ctx.html(final_html)
}

// curl -H "Accept-Language: en" --compressed http://localhost:9009/locale
// curl -H "Accept-Language: zh" --compressed http://localhost:9009/locale
@['/locale'; get]
pub fn (app &AliasApp) locale(mut ctx Context) veb.Result {
	result := {
		'success':        ctx.t('common.success') or { '成功' }
		'create_success': ctx.t('common.createSuccess') or { '新建成功' }
		'init':           ctx.t('init.alreadyInit') or { '数据库已被初始化。' }
	}
	return ctx.json(result)
}

// API 文档查看器；HTML 属于可部署静态资源，文档生成逻辑在 route_openapi.v。
@['/static/rapidoc'; get]
fn (app &AliasApp) rapidoc(mut ctx Context) veb.Result {
	return ctx.file(os.join_path(os.getwd(), 'static', 'openapi', 'rapidoc.html'))
}

@['/static/redoc'; get]
fn (app &AliasApp) redoc(mut ctx Context) veb.Result {
	return ctx.file(os.join_path(os.getwd(), 'static', 'openapi', 'redoc.html'))
}

@['/static/sleapidoc'; get]
fn (app &AliasApp) stoplight_elements(mut ctx Context) veb.Result {
	return ctx.file(os.join_path(os.getwd(), 'static', 'openapi', 'stoplight_elements.html'))
}

@['/static/scalar'; get]
fn (app &AliasApp) scalar(mut ctx Context) veb.Result {
	return ctx.file(os.join_path(os.getwd(), 'static', 'openapi', 'scalar.html'))
}

// http://localhost:9009/static/openapi.json 获取由 veb 路由元数据实时生成的 OpenAPI 文档
@['/static/openapi.json'; get]
fn (app &AliasApp) openapi_json(mut ctx Context) veb.Result {
	if !app.openapi_ready {
		ctx.res.set_status(.service_unavailable)
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'OpenAPI document is not initialized'
		))
	}
	return app.openapi_document.serve(mut ctx.Context, true) or {
		ctx.res.set_status(.internal_server_error)
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg:  'Failed to render OpenAPI document: ${err}'
		))
	}
}

// curl -H "Accept-Language: zh" --compressed http://localhost:9009/locale/debug
@['/locale/debug'; get]
pub fn (app &AliasApp) locale_debug(mut ctx Context) veb.Result {
	// 获取语言，如果请求头中没有语言，则回退到默认语言
	lang := ctx.extra_locale['lang'] or { ctx.locale.default_lang }

	// 获取当前语言的翻译数据，如果语言不存在则回退到默认语言
	translations := if lang in ctx.locale.translations {
		ctx.locale.translations[lang]
	} else {
		ctx.locale.translations[ctx.locale.default_lang]
	}

	// 构造结果并返回
	mut result := map[string]string{}
	for k, v in translations {
		result[k] = v
	}

	return ctx.json(result)
}
