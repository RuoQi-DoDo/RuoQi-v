module route

import log
import model { Context }
import service.fms_api { Fms }

// =============================================================================
// 文件管理 路由注册
//
// 本地文件、云文件、标签、存储提供商
// 使用 register_routes_platform（管理端接口）
// 单控制器 Fms 注册在 /fms，handler 内部用 entity 前缀区分资源
// =============================================================================

fn (mut app AliasApp) routes_fms(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.register_routes_platform[Fms](mut &Fms{}, '/fms', mut ctx)
}
