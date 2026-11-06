module route

import log
import veb
import model { Context }
import service.platform_service.platform_api { PlatformApi }
import service.platform_service.platform_menu { PlatformMenu }
import service.platform_service.platform_dictionary { PlatformDictionary }
import service.platform_service.platform_configuration { PlatformConfiguration }

// =============================================================================
// Platform 路由注册 — 平台级管理（Sys 认证）
// =============================================================================

fn (mut app AliasApp) routes_platform(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// API 管理
	app.register_routes_platform[PlatformApi](mut &PlatformApi{}, '/platform/api', mut ctx)

	// 菜单管理
	app.register_routes_platform[PlatformMenu](mut &PlatformMenu{}, '/platform/menu', mut ctx)

	// 数据字典
	app.register_routes_platform[PlatformDictionary](mut &PlatformDictionary{}, '/platform/dictionary', mut ctx)

	// 系统配置
	app.register_routes_platform[PlatformConfiguration](mut &PlatformConfiguration{}, '/platform/configuration', mut ctx)
}

fn openapi_tags_platform() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'platform'
			summary:     '平台管理'
			description: '平台级 API、菜单、字典和系统配置。'
		},
		veb.OpenApiTagConfig{
			name:        'platform.api'
			summary:     'API 注册'
			description: '平台接口资源注册与权限定义。'
			parent:      'platform'
			controllers: [typeof(PlatformApi{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'platform.menu'
			summary:     '菜单'
			description: '平台菜单与导航配置。'
			parent:      'platform'
			controllers: [typeof(PlatformMenu{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'platform.dictionary'
			summary:     '数据字典'
			description: '平台字典及字典明细。'
			parent:      'platform'
			controllers: [typeof(PlatformDictionary{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'platform.configuration'
			summary:     '系统配置'
			description: '平台运行时配置项。'
			parent:      'platform'
			controllers: [typeof(PlatformConfiguration{}).name.trim_left('&')]
		},
	]
}
