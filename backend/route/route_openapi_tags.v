module route

import veb

// openapi_tags combines the public OpenAPI taxonomy contributed by each route
// domain. Keep controller mappings next to their register_routes_* function.
fn openapi_tags() []veb.OpenApiTagConfig {
	mut tags := openapi_tags_base()
	tags << openapi_tags_iam()
	tags << openapi_tags_workspace()
	tags << openapi_tags_platform()
	tags << openapi_tags_tenant()
	tags << openapi_tags_fms()
	tags << openapi_tags_msg()
	tags << openapi_tags_job()
	tags << openapi_tags_pay()
	tags << openapi_tags_system()
	tags << openapi_tags_system_docs()
	tags << openapi_tags_base_mcp()
	tags << openapi_tags_database()
	return tags
}

fn openapi_tags_system() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'system'
			summary:     '系统'
			description: '运行时文档、MCP 和数据库维护。'
		},
	]
}
