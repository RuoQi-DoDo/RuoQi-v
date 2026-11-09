module route

import log
import veb
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

fn openapi_tags_workspace() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'workspace'
			summary:     '工作区'
			description: '工作区、成员、部门、岗位和权限管理。'
		},
		veb.OpenApiTagConfig{
			name:        'workspace.core'
			summary:     '工作区核心'
			description: '工作区、成员和角色权限。'
			parent:      'workspace'
			controllers: [typeof(WorkspaceCore{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'workspace.department'
			summary:     '部门'
			description: '工作区部门维护。'
			parent:      'workspace'
			controllers: [typeof(WorkspaceDepartment{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'workspace.position'
			summary:     '岗位'
			description: '工作区岗位维护。'
			parent:      'workspace'
			controllers: [typeof(WorkspacePosition{}).name.trim_left('&')]
		},
	]
}
