module route

import log
import model { Context }
import service.workspace_service.workspace_core { WorkspaceCore }
import service.workspace_service.workspace_department { WorkspaceDepartment }
import service.workspace_service.workspace_position { WorkspacePosition }

// =============================================================================
// Workspace 路由注册 — 工作区管理（IAM 认证 + datascope）
// =============================================================================

fn (mut app AliasApp) routes_workspace(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 工作区 CRUD + 成员 + 权限
	app.register_routes_workspace[WorkspaceCore](mut &WorkspaceCore{}, '/workspace/core', mut ctx)

	// 部门管理
	app.register_routes_workspace[WorkspaceDepartment](mut &WorkspaceDepartment{}, '/workspace/department', mut ctx)

	// 岗位管理
	app.register_routes_workspace[WorkspacePosition](mut &WorkspacePosition{}, '/workspace/position', mut ctx)
}
