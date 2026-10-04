module base_mcp

import common.mcp
import adapter.dbpool
import service_mcp.base_mcp.currency
import service_mcp.base_mcp.language
import service_mcp.base_mcp.region
import service_mcp.base_mcp.region_adm_div
import service_mcp.base_mcp.utc

pub const server_name = 'ruoqi-base-mcp'
pub const server_version = '0.1.0'

// new_server builds the base master-data MCP server.
//
// Every tool is registered against the shared database pool, so the caller owns
// the pool lifecycle (open before `new_server`, close after the server stops).
pub fn new_server(pool &dbpool.DatabasePoolable) !mcp.Server {
	mut server := mcp.new_server(
		name:            server_name
		version:         server_version
		title:           'RuoQi Base MCP'
		description:     'MCP tools over RuoQi base master data: currency, language, region, administrative division and UTC.'
		instructions:    'Use the base_* tools to query and maintain base master data. Delete tools are soft-deletes (del_flag = -1).'
		enable_logging:  true
		// Tighten this list for any deployment that is not loopback-only.
		allowed_origins: ['*']
	)

	currency.register_currency_tools(mut server, pool)!
	language.register_language_tools(mut server, pool)!
	region.register_region_tools(mut server, pool)!
	region_adm_div.register_region_adm_tools(mut server, pool)!
	utc.register_utc_tools(mut server, pool)!

	return server
}
