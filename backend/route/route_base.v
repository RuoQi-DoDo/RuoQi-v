module route

import log
import veb
import model { Context }
import service.base_api.currency { Currency }
import service.base_api.language { Language }
import service.base_api.region { Region }
import service.base_api.region_adm_div { RegionAdmDiv }
import service.base_api.utc { Utc }

fn (mut app AliasApp) routes_sys_base(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 不需要token_jwt 认证
	app.register_routes_no_auth[Currency](mut &Currency{}, '/base/currency', mut ctx)
	app.register_routes_no_auth[Language](mut &Language{}, '/base/language', mut ctx)
	app.register_routes_no_auth[Region](mut &Region{}, '/base/region', mut ctx)
	app.register_routes_no_auth[RegionAdmDiv](mut &RegionAdmDiv{}, '/base/region_adm_div', mut ctx)
	app.register_routes_no_auth[Utc](mut &Utc{}, '/base/utc', mut ctx)
}

fn openapi_tags_base() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'base'
			summary:     '基础数据'
			description: '国家地区、语言、货币和时区等公共基础资料。'
		},
		veb.OpenApiTagConfig{
			name:        'base.currency'
			summary:     '货币'
			description: '基础货币资料的查询与维护。'
			parent:      'base'
			controllers: [typeof(Currency{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'base.language'
			summary:     '语言'
			description: '系统支持语言的查询与维护。'
			parent:      'base'
			controllers: [typeof(Language{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'base.region'
			summary:     '国家与地区'
			description: '国家地区主数据的查询与维护。'
			parent:      'base'
			controllers: [typeof(Region{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'base.region_adm_div'
			summary:     '行政区划'
			description: '国家地区下级行政区划的查询与维护。'
			parent:      'base'
			controllers: [typeof(RegionAdmDiv{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'base.utc'
			summary:     '时区'
			description: 'UTC 时区偏移资料的查询与维护。'
			parent:      'base'
			controllers: [typeof(Utc{}).name.trim_left('&')]
		},
	]
}
