module middleware

import veb
import model { Context }
import common.reqid

// request_id_middleware 在请求入口确定本次调用的唯一 id：
//   1. 优先透传上游（网关/客户端）的 X-Request-Id；
//   2. 没有或格式不合法时生成 uuid_v7；
// 然后写入 Context、线程级请求上下文（日志与响应体共用）和响应头。
//
// 必须注册为最早执行的全局中间件，保证后续所有日志都带上该 id。
//
// registry 由 main 创建，通过闭包注入（项目不使用全局变量）。
pub fn request_id_middleware(registry &reqid.Registry) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [registry] (mut ctx Context) bool {
			mut id := reqid.sanitize(ctx.req.header.get_custom('X-Request-Id') or { '' })
			if id == '' {
				id = reqid.generate()
			}
			ctx.request_id = id
			registry.set(id)
			ctx.res.header.add_custom('X-Request-Id', id) or {}
			return true
		}
	}
}
