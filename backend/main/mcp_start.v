module main

import log
import adapter.dbpool
import common.mcp
import service_mcp.base_mcp

// new_base_mcp_server builds the embedded base master-data MCP server.
//
// The server does not own a socket: it is mounted on the existing veb listener
// through the `/mcp` route (see backend/route/route_base_mcp.v). Returns `nil`
// when the server cannot be built; that route then answers 503.
pub fn new_base_mcp_server(pool &dbpool.DatabasePoolable) &mcp.Server {
	mut server := base_mcp.new_server(pool) or {
		log.error('base_mcp: failed to build server: ${err}')
		return unsafe { nil }
	}
	log.info('base_mcp: MCP server mounted at /mcp')
	return &server
}
