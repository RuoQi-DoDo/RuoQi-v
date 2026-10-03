module route

import log
import veb
import model { App, Context }
import adapter.datascope { ScopeConfig, ScopeField }
import middleware

// 通用中间件设置函数 - 减少代码重复
pub fn (mut app AliasApp) common_middleware(mut ctrl App, mut ctx Context) {
	ctrl.use(middleware.cores_middleware_generic())
	ctrl.use(middleware.logger_middleware_generic())
	ctrl.use(middleware.config_middle(ctx.config))
	ctrl.use(middleware.db_middleware(ctx.dbpool))
	ctrl.use(middleware.locale_middleware(ctx.locale))
}

fn (mut app AliasApp) register_routes_no_auth[T](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware(mut ctrl.App, mut ctx)
	app.register_controller[T, Context](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_authenticated[T](mut ctrl T, url_path string, mut ctx Context) {
	ctrl.use(middleware.iam_identity_middleware())
	app.common_middleware(mut ctrl.App, mut ctx)
	app.register_controller[T, Context](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_platform[T](mut ctrl T, url_path string, mut ctx Context) {
	ctrl.use(middleware.iam_full_middleware())
	app.common_middleware(mut ctrl.App, mut ctx)
	ctrl.use(middleware.datascope_middleware(ScopeConfig{ enabled_fields: []ScopeField{} }))
	app.register_controller[T, Context](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

// register_routes_scoped — 身份认证 + 租户成员校验 + datascope 隔离
// 用于：会员端、顾客端等需要租户数据隔离但不需要 workspace 权限的端点
fn (mut app AliasApp) register_routes_scoped[T](mut ctrl T, url_path string, mut ctx Context) {
	ctrl.use(middleware.iam_scoped_middleware())
	app.common_middleware(mut ctrl.App, mut ctx)
	ctrl.use(middleware.datascope_middleware(ScopeConfig{
		enabled_fields: [ScopeField.tenant_id]
	}))
	app.register_controller[T, Context](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_workspace[T](mut ctrl T, url_path string, mut ctx Context) {
	ctrl.use(middleware.iam_full_middleware())
	app.common_middleware(mut ctrl.App, mut ctx)
	ctrl.use(middleware.datascope_middleware(ScopeConfig{
		enabled_fields: [
			ScopeField.tenant_id,
			ScopeField.workspace_id,
		]
	}))
	app.register_controller[T, Context](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}
