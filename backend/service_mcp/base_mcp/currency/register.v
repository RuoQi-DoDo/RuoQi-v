module currency

import mcp
import adapter.dbpool

// register_currency_tools registers every base currency MCP tool on server.
pub fn register_currency_tools(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	find_currency_all_tool(mut server, pool)!
	create_currency_tool(mut server, pool)!
	update_currency_tool(mut server, pool)!
	delete_currency_tool(mut server, pool)!
}
