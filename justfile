# RuoQi-v 项目命令
# ─── 微服务选择 ─────────────────────────────────────
# 服务名对应 backend/route/route_cfg.v 的条件编译分支，默认 all（单体，全部路由）：
#   all 单体 / fms 文件 / iam 核心（身份+工作空间）/ job 任务 / mcms 消息 /
#   pay 支付 / tenant 租户 / platform 平台 / mcp 基础资料（/base + /mcp）
# 用法：just dev mcp、just build fms、SERVICE=iam just test、just build（默认 all）

service := env_var_or_default("SERVICE", "all")
services := "all fms iam job mcms pay tenant platform mcp"

# 校验服务名：拼错时直接报错，避免未知 -d 标志静默落到 All 分支
_check_service s:
    @case " {{ services }} " in *" "{{ s }}" "*) ;; *) echo "未知服务 '{{ s }}'，可选：{{ services }}" >&2; exit 1 ;; esac

# ─── 开发 ───────────────────────────────────────────

# 带 watch 的开发模式；可选服务名：just dev mcp
dev s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation -d trace_orm -d veb_livereload {{ if s == "all" { "" } else { "-d " + s } }} watch run ./main -f etc/config_dev.toml

# 单次运行 dev 配置；可选服务名：just test mcp
test s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config_dev.toml

# 单次运行 uat 配置；可选服务名：just uat iam
uat s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config.toml

# 编译到 backend/app；可选服务名：just build fms
build s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 生产编译；可选服务名：just build-prod pay
build-prod s=service: (_check_service s)
    cd backend && v -prod -new-compiler {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# ─── OpenAPI ────────────────────────────────────────
openapi:
    cd backend && v run openapi/openapi_generate.vsh

# ─── 前端 ──────────────────────────────────────────
frontend_get:
    cd frontend && flutter pub get

frontend_analyze:
    cd frontend && melos analyze

frontend_test:
    cd frontend && melos test

frontend_gen:
    cd frontend && melos gen

# 启动平台 Flutter 原型服务。
# 默认 web-server 模式：只起本地服务，用任意浏览器打开下方地址访问。

# 想用设备直接跑可覆盖，如：just platform_pc linux
platform_pc DEVICE="web-server" PORT="51000":
    cd frontend/apps/platform_pc && flutter run -d {{ DEVICE }} --web-port {{ PORT }}

platform_app DEVICE="web-server" PORT="51001":
    cd frontend/apps/platform_app && flutter run -d {{ DEVICE }} --web-port {{ PORT }}

# 业务端原型服务（客户 / 商户 / 伙伴三个业务域共用一个应用壳）
business_pc DEVICE="web-server" PORT="51002":
    cd frontend/apps/business_pc && flutter run -d {{ DEVICE }} --web-port {{ PORT }}

business_app DEVICE="web-server" PORT="51003":
    cd frontend/apps/business_app && flutter run -d {{ DEVICE }} --web-port {{ PORT }}

# 一条命令并行拉起全部 4 个原型（51000-51003）+ 静态入口页（51090）。
# 打开 http://localhost:51090 一页点进所有端；Ctrl-C 全部停止。
# 覆盖示例：just apps chrome 51010 51099

# 也可用环境变量：DEVICE=chrome BASE_PORT=51010 HUB_PORT=51099 just apps
apps device=env_var_or_default("DEVICE", "web-server") base_port=env_var_or_default("BASE_PORT", "51000") hub_port=env_var_or_default("HUB_PORT", "51090"):
    DEVICE={{ device }} BASE_PORT={{ base_port }} HUB_PORT={{ hub_port }} ./frontend/tools/dev_all.sh

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9
