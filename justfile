# RuoQi-v 项目命令
# ─── 微服务选择 ─────────────────────────────────────
# 服务名对应 backend/route/route_cfg.v 的条件编译分支，默认 all（单体，全部路由）：
#   all 单体 / fms 文件 / iam 核心（身份+工作空间）/ job 任务 / mcms 消息 /
#   pay 支付 / tenant 租户 / platform 平台 / mcp 基础资料（/base + /mcp）/
#   db 数据库初始化（/database）
# 用法：just run-dev-tcc mcp、just build-tcc fms、SERVICE=iam just run-test-x64
# 用 bash 执行 recipe：time 是 bash 保留字，默认的 sh(dash) 里不存在

set shell := ["bash", "-uc"]

service := env_var_or_default("SERVICE", "all")
services := "all fms iam job mcms pay tenant platform mcp db"

# 校验服务名：拼错时直接报错，避免未知 -d 标志静默落到 All 分支
_check_service s:
    @case " {{ services }} " in *" "{{ s }}" "*) ;; *) echo "未知服务 '{{ s }}'，可选：{{ services }}" >&2; exit 1 ;; esac

# ─── 后端 ───────────────────────────────────────────

# 带 watch 的开发模式（x64）；可选服务名：just run-dev-x64 mcp
run-dev-x64 s=service: (_check_service s)
    cd backend && env V3_PARALLEL_MONOMORPHIZE=1 v -new-compiler -d x64 -no-retry-compilation -d trace_orm -d veb_livereload {{ if s == "all" { "" } else { "-d " + s } }} watch run ./main -f etc/config_dev.toml

# 带 watch 的开发模式（tcc）；可选服务名：just run-dev-tcc mcp
run-dev-tcc s=service: (_check_service s)
    cd backend && env V3_PARALLEL_MONOMORPHIZE=1 v -new-compiler -cc tcc -no-retry-compilation -d trace_orm -d veb_livereload {{ if s == "all" { "" } else { "-d " + s } }} watch run ./main -f etc/config_dev.toml

# 单次运行 dev 配置（x64）；可选服务名：just run-test-x64 mcp
run-test-x64 s=service: (_check_service s)
    cd backend && v -new-compiler -d x64 -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config_dev.toml

# 单次运行 dev 配置（tcc）；可选服务名：just run-test-tcc mcp
run-test-tcc s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config_dev.toml

# 编译到 backend/app（x64）；可选服务名：just build-x64 fms
build-x64 s=service: (_check_service s)
    cd backend && time v -no-prealloc -new-compiler -stats -d x64 -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（tcc）；可选服务名：just build-tcc fms
build-tcc s=service: (_check_service s)
    cd backend && time v -no-prealloc -new-compiler -stats -cc tcc -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（x64 + ownership）；可选服务名：just build-x64-owership fms
build-x64-owership s=service: (_check_service s)
    cd backend && time v -ownership -autofree -gc none -no-prealloc -new-compiler -stats -d x64 -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（tcc + V 自带 GC）；可选服务名：just build-tcc-vgc fms
build-tcc-vgc s=service: (_check_service s)
    cd backend && time v -autofree -gc vgc -no-prealloc -new-compiler -stats -cc tcc -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（x64 + V 自带 GC）；可选服务名：just build-x64-vgc fms
build-x64-vgc s=service: (_check_service s)
    cd backend && time v -autofree -gc vgc -no-prealloc -new-compiler -stats -d x64 -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 生产编译（默认 C 后端）；可选服务名：just build-prod-c pay
build-prod-c s=service: (_check_service s)
    cd backend && time v -ownership -new-compiler -prod -stats {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 生产编译（x64）；可选服务名：just build-prod-x64 pay
build-prod-x64 s=service: (_check_service s)
    cd backend && time v -ownership -new-compiler -prod -stats -d x64 {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

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
