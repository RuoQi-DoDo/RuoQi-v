module route

import log
import net.http
import veb
import model { Context }

// index — /mcp 上的 GET / POST / DELETE（MCP Streamable HTTP）。
@['/'; post; get; delete]
fn (c &BaseMcp) index(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	if isnil(c.mcp_server) {
		ctx.res.set_status(.service_unavailable)
		return ctx.send_response_to_client('application/json',
			'{"error":"base mcp server is not available"}')
	}

	resp_value := c.mcp_server.handle_http_request(ctx.req)
	// http.Response methods use value receivers, so keep one heap owner and
	// borrow all response fields and methods through it.
	resp := &http.Response{
		body:         resp_value.body
		header:       resp_value.header
		trailers:     resp_value.trailers
		status_code:  resp_value.status_code
		status_msg:   resp_value.status_msg
		http_version: resp_value.http_version
	}

	ctx.res.set_status(resp.status())
	for key in resp.header.keys() {
		for value in resp.header.custom_values(key.clone(), exact: true) {
			ctx.set_custom_header(key, value) or {}
		}
	}
	mime := resp.header.get(.content_type) or { 'application/json' }
	return ctx.send_response_to_client(mime, resp.body)
}

// routes_base_mcp — 挂载基础资料 MCP 服务：/mcp。
//
// MCP 工具操作的是基础资料表（货币 / 语言 / 国家地区 / 行政区划 / UTC），
// 因此与 routes_sys_base 同源部署：需要基础资料的服务一并开放 MCP。
fn (mut app AliasApp) routes_base_mcp(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut ctrl := &BaseMcp{
		mcp_server: app.mcp_server
	}
	app.register_routes_no_auth[BaseMcp](mut ctrl, '/mcp', mut ctx)
}
