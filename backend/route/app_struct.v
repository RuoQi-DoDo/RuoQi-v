module route

import veb
import model { App }
import mcp

pub struct AliasApp {
	App
pub mut:
	// mcp_server is the embedded base MCP server, dispatched in-process by the
	// `/mcp` route. nil when unavailable.
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
