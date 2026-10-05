module utc

import mcp
import adapter.dbpool

// register_utc_tools registers every base UTC time zone MCP tool on server.
pub fn register_utc_tools(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	find_utc_all_tool(mut server, pool)!
	create_utc_tool(mut server, pool)!
	update_utc_tool(mut server, pool)!
	delete_utc_tool(mut server, pool)!
}
