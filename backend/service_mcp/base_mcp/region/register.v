module region

import common.mcp
import adapter.dbpool

// register_region_tools registers every base region MCP tool on server.
pub fn register_region_tools(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	find_region_all_tool(mut server, pool)!
	create_region_tool(mut server, pool)!
	update_region_tool(mut server, pool)!
	delete_region_tool(mut server, pool)!
}
