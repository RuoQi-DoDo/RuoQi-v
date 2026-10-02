module route

import log
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
