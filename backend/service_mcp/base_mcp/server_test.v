module base_mcp

import net.http

// The pool is only dereferenced inside a tool call, so registration can be
// exercised without a live database. This catches duplicate/!invalid tool names
// and broken tool input schemas at test time.
fn test_new_server_registers_all_tools() {
	server := new_server(unsafe { nil }) or { panic(err) }
	_ := server
}

// The MCP server no longer owns a socket, so a full request can be dispatched
// in-process. This exercises the same path the `/mcp` veb route uses.
fn test_handle_initialize_request_in_process() {
	mut server := new_server(unsafe { nil }) or { panic(err) }

	mut header := http.new_header()
	header.set(.content_type, 'application/json')
	header.set(.accept, 'application/json')

	req := http.Request{
		method: .post
		url:    '/mcp'
		header: header
		data:   '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}'
	}

	resp := server.handle_http_request(req)
	assert resp.status_code == 200
	assert resp.body.contains('protocolVersion')
}
