module route

import log
import veb
import model { Context }
import service.iam_service.iam_api { Iam }
import service.iam_service.iam_api.authentication { Authentication }
import service.iam_service.iam_api.user { User }
import service.iam_service.iam_api.profile { Profile }
import service.iam_service.iam_api.token { Token }
import service.iam_service.iam_api.apikey { ApiKey }
import service.iam_service.iam_api.tenant { Tenant }

// =============================================================================
// IAM 路由注册
//
// 无需认证：auth（登录/注册/MFA）
// 仅认证（自服务）：profile / token / tenant — 已登录即可访问
// 身份+租户隔离：tenants — 租户成员校验 + datascope（未来会员端 API 用此模式）
// 全量认证+授权：user / apikey — 需 workspace 权限（admin 通过 workspace_admin 角色获得 all）
// =============================================================================

fn (mut app AliasApp) routes_iam(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 无需认证 —— 认证入口 + 注册 + MFA
	app.register_routes_no_auth[Iam](mut &Iam{}, '/iam', mut ctx)
	app.register_routes_no_auth[Authentication](mut &Authentication{}, '/iam/auth', mut ctx)

	// 仅认证（自服务）—— 已登录即可访问，不检查 workspace 权限
	app.register_routes_authenticated[Profile](mut &Profile{}, '/iam/profile', mut ctx)
	app.register_routes_authenticated[Token](mut &Token{}, '/iam/token', mut ctx)
	app.register_routes_authenticated[Tenant](mut &Tenant{}, '/iam/tenant', mut ctx)

	// 全量认证+授权 —— 需要 workspace 权限
	app.register_routes_platform[User](mut &User{}, '/iam/user', mut ctx)
	app.register_routes_platform[ApiKey](mut &ApiKey{}, '/iam/apikey', mut ctx)
}

fn openapi_tags_iam() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'iam'
			summary:     '身份与权限'
			description: '登录、账号、令牌、角色与访问密钥。'
		},
		veb.OpenApiTagConfig{
			name:        'iam.authentication'
			summary:     '认证'
			description: '账号注册、登录、验证码和密码重置。'
			parent:      'iam'
			controllers: [typeof(Authentication{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.profile'
			summary:     '个人资料'
			description: '当前用户的个人资料维护。'
			parent:      'iam'
			controllers: [typeof(Profile{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.token'
			summary:     '令牌'
			description: '访问令牌的查询、刷新和撤销。'
			parent:      'iam'
			controllers: [typeof(Token{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.tenant_access'
			summary:     '租户入口'
			description: '当前登录用户可访问的租户。'
			parent:      'iam'
			controllers: [typeof(Tenant{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.user'
			summary:     '用户'
			description: '管理端用户账号维护。'
			parent:      'iam'
			controllers: [typeof(User{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.api_key'
			summary:     'API Key'
			description: '开放接口访问密钥的创建和生命周期管理。'
			parent:      'iam'
			controllers: [typeof(ApiKey{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'iam.root'
			summary:     'IAM 入口'
			description: '身份服务根路由。'
			parent:      'iam'
			controllers: [typeof(Iam{}).name.trim_left('&')]
		},
	]
}
