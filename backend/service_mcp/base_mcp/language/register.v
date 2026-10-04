module language

import common.mcp
import adapter.dbpool

// register_language_tools registers every base language MCP tool on server.
pub fn register_language_tools(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	find_language_all_tool(mut server, pool)!
	create_language_tool(mut server, pool)!
	update_language_tool(mut server, pool)!
	delete_language_tool(mut server, pool)!
}
