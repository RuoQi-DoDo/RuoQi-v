module route

import log
import model { Context }

// 根据条件编译，选择运行的服务（微服务拆分部署用 `v -d <flag>`）
//
// 使用 $else $if 链式条件，确保每个编译标志只命中一个分支，避免路由重复注册。
//
// | 编译标志 | 服务                      | 路由组                                                |
// | -------- | ------------------------- | ----------------------------------------------------- |
// | fms      | 文件服务                  | fms                                                   |
// | iam      | 核心服务（身份/工作空间） | iam、workspace                                        |
// | job      | 任务服务                  | job                                                   |
// | mcms     | 消息服务                  | msg                                                   |
// | pay      | 支付服务                  | pay                                                   |
// | tenant   | 租户服务                  | tenant                                                |
// | platform | 平台服务（Sys）           | platform                                              |
// | mcp      | 基础资料服务              | sys_base、base_mcp（基础资料 API + MCP 工具）         |
// | 无标志   | 单体（默认，All）         | db、sys_base、base_mcp、iam、platform、workspace、    |
// |          |                           | msg、pay、fms、job、tenant                            |
pub fn (mut app AliasApp) setup_conditional_routes(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	$if fms ? {
		// 文件服务：/fms
		log.warn('routes_ifdef - Fms')
		app.routes_fms(mut ctx)
	} $else $if iam ? {
		// 核心服务：/iam 身份认证 + /workspace 工作空间
		log.warn('routes_ifdef - Core')
		app.routes_iam(mut ctx)
		app.routes_workspace(mut ctx)
	} $else $if job ? {
		// 任务服务：/job
		log.warn('routes_ifdef - Job')
		app.routes_job(mut ctx)
	} $else $if mcms ? {
		// 消息服务：/msg
		log.warn('routes_ifdef - Mcms')
		app.routes_msg(mut ctx)
	} $else $if pay ? {
		// 支付服务：/pay
		log.warn('routes_ifdef - Pay')
		app.routes_pay(mut ctx)
	} $else $if tenant ? {
		// 租户服务：/tenant（身份 + 租户隔离）
		log.warn('routes_ifdef - Tenant')
		app.routes_tenant(mut ctx)
	} $else $if platform ? {
		// 平台服务：/platform
		log.warn('routes_ifdef - Sys')
		app.routes_platform(mut ctx)
	} $else $if mcp ? {
		// 基础资料服务：/base 基础资料 API + /mcp MCP 工具（同源数据）
		log.warn('routes_ifdef - Mcp')
		app.routes_sys_base(mut ctx)
		app.routes_base_mcp(mut ctx)
	} $else {
		// 单体：全部路由（开发/单实例部署）
		log.warn('routes_ifdef - All')
		app.routes_db(mut ctx)
		app.routes_sys_base(mut ctx)
		app.routes_base_mcp(mut ctx)
		app.routes_iam(mut ctx)
		app.routes_platform(mut ctx)
		app.routes_workspace(mut ctx)
		app.routes_msg(mut ctx)
		app.routes_pay(mut ctx)
		app.routes_fms(mut ctx)
		app.routes_job(mut ctx)
		app.routes_tenant(mut ctx)
	}
}
