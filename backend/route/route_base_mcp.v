module route

import log
import model { Context }
import veb

// /mcp — Streamable HTTP endpoint for the embedded base master-data MCP server.
//
// veb owns the listener/port; the request is dispatched in-process to the MCP
// server, so no extra port or reverse-proxy hop is involved.
@['/mcp'; post; get; delete]
pub fn (mut app AliasApp) base_mcp_proxy(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	if isnil(app.mcp_server) {
		ctx.res.set_status(.service_unavailable)
		return ctx.send_response_to_client('application/json',
			'{"error":"base mcp server is not available"}')
	}

	resp := app.mcp_server.handle_http_request(ctx.req)

	ctx.res.set_status(resp.status())
	for key in resp.header.keys() {
		for value in resp.header.custom_values(key, exact: true) {
			ctx.set_custom_header(key, value) or {}
		}
	}
	mime := resp.header.get(.content_type) or { 'application/json' }
	return ctx.send_response_to_client(mime, resp.body)
}
