module route

import log
import veb
import model { Context }
import service.job_api.task { Task }
import service.job_api.tasklog { TaskLog }

// =============================================================================
// 定时任务 路由注册
//
// 系统定时任务的 CRUD 和日志查询
// 全使用 register_routes_platform（管理端接口）
// =============================================================================

fn (mut app AliasApp) routes_job(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// Task management
	app.register_routes_platform[Task](mut &Task{}, '/job/task', mut ctx)

	// Task log management
	app.register_routes_platform[TaskLog](mut &TaskLog{}, '/job/tasklog', mut ctx)
}

fn openapi_tags_job() []veb.OpenApiTagConfig {
	return [
		veb.OpenApiTagConfig{
			name:        'job'
			summary:     '定时任务'
			description: '定时任务配置与执行日志。'
		},
		veb.OpenApiTagConfig{
			name:        'job.task'
			summary:     '任务'
			description: '定时任务配置。'
			parent:      'job'
			controllers: [typeof(Task{}).name.trim_left('&')]
		},
		veb.OpenApiTagConfig{
			name:        'job.task_log'
			summary:     '任务日志'
			description: '定时任务执行记录。'
			parent:      'job'
			controllers: [typeof(TaskLog{}).name.trim_left('&')]
		},
	]
}
