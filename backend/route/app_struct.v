module route

import veb
import model { App }
import mcp

pub struct AliasApp {
	App
pub mut:
	// mcp_server is the embedded base MCP server, dispatched in-process by the
	// `/mcp` route mounted from routes_base_mcp(). nil when unavailable.
	mcp_server &mcp.Server = unsafe { nil }
}

// BaseMcp — 基础资料 MCP 服务的 HTTP 控制器（Streamable HTTP，挂载在 /mcp）。
//
// veb 负责监听端口，请求在进程内交给 MCP server 处理；不额外占用端口，
// 也没有反向代理跳数。控制器由 routes_base_mcp() 按服务条件注册，
// 未启用 MCP 的构建不会暴露 /mcp（注册见 route_base_mcp.v）。
pub struct BaseMcp {
	App
pub mut:
	// mcp_server 取自 AliasApp，是共享的基础资料 MCP server；nil 时 /mcp 返回 503。
	mcp_server &mcp.Server = unsafe { nil }
}

// init_server stores the veb server handle for graceful shutdown.
pub fn (mut app AliasApp) init_server(server &veb.Server) {
	app.server = server
}

// request_shutdown notifies the main app lifecycle once without blocking.
pub fn (app &AliasApp) request_shutdown() {
	app.shutdown_signal.try_push(true)
}
