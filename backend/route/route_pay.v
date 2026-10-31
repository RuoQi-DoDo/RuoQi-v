module route

import log
import model { Context }
import service.pay_api.demo_order { DemoOrder }
import service.pay_api.order { Order }
import service.pay_api.order_extension { OrderExtension }
import service.pay_api.refund { Refund }

// =============================================================================
// 支付 路由注册
//
// 支付订单、退款、示例订单、订单扩展
// 使用 register_routes_platform（common + iam_full）
// 每个资源子模块使用独立 controller，保持原完整 URL 不变。
// =============================================================================

fn (mut app AliasApp) routes_pay(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	app.register_routes_platform[Order](mut &Order{}, '/pay/order', mut ctx)
	app.register_routes_platform[OrderExtension](mut &OrderExtension{}, '/pay/extension', mut ctx)
	app.register_routes_platform[Refund](mut &Refund{}, '/pay/refund', mut ctx)
	app.register_routes_platform[DemoOrder](mut &DemoOrder{}, '/pay/demo', mut ctx)
}
