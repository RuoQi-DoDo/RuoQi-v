module route

import log
import model { Context }
import service.pay_api { Pay }

// =============================================================================
// 支付 路由注册
//
// 支付订单、退款、示例订单、订单扩展
// 使用 register_routes_platform（common + iam_full）
// 单控制器 Pay 注册在 /pay，handler 内部用 entity 前缀区分路由
// =============================================================================

fn (mut app AliasApp) routes_pay(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.register_routes_platform[Pay](mut &Pay{}, '/pay', mut ctx)
}
