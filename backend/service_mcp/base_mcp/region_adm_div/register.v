module region_adm_div

import common.mcp
import adapter.dbpool

// register_region_adm_tools registers every base administrative division MCP tool on server.
pub fn register_region_adm_tools(mut server mcp.Server, pool &dbpool.DatabasePoolable) ! {
	find_region_adm_all_tool(mut server, pool)!
	create_adm_tool(mut server, pool)!
	update_adm_tool(mut server, pool)!
	delete_adm_tool(mut server, pool)!
}
