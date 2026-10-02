module route

import log
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
