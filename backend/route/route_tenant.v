module route

import log
import veb
import model { Context }
import service.tenant_service.tenant_subproduct { TenantSubProduct }
import service.tenant_service.tenant_member { TenantMember }
import service.tenant_service.tenant_invoice { TenantInvoice }
import service.tenant_service.tenant_config { TenantConfig }

// =============================================================================
// Tenant 路由注册 — 租户自服务门户（scoped 认证）
//
// scoped 中间件：JWT 身份 + tn_member 校验 + tenant_id datascope 隔离
// 用户需携带 X-Tenant-ID / X-Product-ID / X-Portal-ID 请求头
// =============================================================================

fn (mut app AliasApp) routes_tenant(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 产品订阅
	app.register_routes_scoped[TenantSubProduct](mut &TenantSubProduct{}, '/tenant/subproduct', mut ctx)

	// 成员管理
	app.register_routes_scoped[TenantMember](mut &TenantMember{}, '/tenant/member', mut ctx)

	// 账单查看
	app.register_routes_scoped[TenantInvoice](mut &TenantInvoice{}, '/tenant/invoice', mut ctx)

	// 租户配置
	app.register_routes_scoped[TenantConfig](mut &TenantConfig{}, '/tenant/config', mut ctx)
}

fn openapi_tags_tenant() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'tenant'
			summary:     '租户服务'
			description: '租户产品订阅、成员、账单和配置。'
		},
		veb.OpenApiTagConfig{
			name:        'tenant.subproduct'
			summary:     '产品订阅'
			description: '租户产品及套餐订阅。'
			parent:      'tenant'
			controllers: [typeof(TenantSubProduct{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'tenant.member'
			summary:     '租户成员'
			description: '租户成员邀请、查询和移除。'
			parent:      'tenant'
			controllers: [typeof(TenantMember{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'tenant.invoice'
			summary:     '账单'
			description: '租户账单查询。'
			parent:      'tenant'
			controllers: [typeof(TenantInvoice{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'tenant.config'
			summary:     '租户配置'
			description: '租户产品运行配置。'
			parent:      'tenant'
			controllers: [typeof(TenantConfig{}).name.trim_left('&')]
		},
	]
}
