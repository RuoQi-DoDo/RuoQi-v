module route

import log
import model { Context }
import middleware
import service.db_api { Database }

fn (mut app AliasApp) routes_db(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	// 方式一: 直接使用中间件，适合对单个控制器单独使用中间件
	mut db_app := &Database{}
	app.openapi_controller_security[typeof(db_app).name.trim_left('&')] = []map[string][]string{}
	db_app.use(handler: middleware.cores_middleware)
	db_app.use(handler: middleware.logger_middleware)
	db_app.use(middleware.config_middle(ctx.config))
	db_app.use(middleware.db_middleware(ctx.dbpool))
	app.register_controller[Database, Context]('/database', mut db_app) or { log.error('${err}') }
}
