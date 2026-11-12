# RuoQi-v 项目命令
# ─── 微服务选择 ─────────────────────────────────────
# 服务名对应 backend/route/route_cfg.v 的条件编译分支，默认 all（单体，全部路由）：
#   all 单体 / fms 文件 / iam 核心（身份+工作空间）/ job 任务 / mcms 消息 /
#   pay 支付 / tenant 租户 / platform 平台 / mcp 基础资料（/base + /mcp）/
#   db 数据库初始化（/database）
# 用法：just run-dev-tcc mcp、just build-tcc fms、SERVICE=iam just run-test-amd64
# 用 bash 执行 recipe：time 是 bash 保留字，默认的 sh(dash) 里不存在

set shell := ["bash", "-uc"]

service := env_var_or_default("SERVICE", "all")
services := "all fms iam job mcms pay tenant platform mcp db"

# 校验服务名：拼错时直接报错，避免未知 -d 标志静默落到 All 分支
_check_service s:
    @case " {{ services }} " in *" "{{ s }}" "*) ;; *) echo "未知服务 '{{ s }}'，可选：{{ services }}" >&2; exit 1 ;; esac

# ─── 后端 ───────────────────────────────────────────

# 带 watch 的开发模式（amd64）；可选服务名：just run-dev-amd64 mcp
run-dev-amd64 s=service: (_check_service s)
    cd backend && env V3_PARALLEL_MONOMORPHIZE=1 v -b amd64 -new-compiler -no-retry-compilation -d trace_orm -d veb_livereload {{ if s == "all" { "" } else { "-d " + s } }} watch run ./main -f etc/config_dev.toml

# 带 watch 的开发模式（tcc）；可选服务名：just run-dev-tcc mcp
run-dev-tcc s=service: (_check_service s)
    cd backend && env V3_PARALLEL_MONOMORPHIZE=1 v -new-compiler -cc tcc -no-retry-compilation -d trace_orm -d veb_livereload {{ if s == "all" { "" } else { "-d " + s } }} watch run ./main -f etc/config_dev.toml

# 单次运行 dev 配置（amd64）；可选服务名：just run-test-amd64 mcp
run-test-amd64 s=service: (_check_service s)
    cd backend && v -b amd64 -new-compiler -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config_dev.toml

# 单次运行 dev 配置（tcc）；可选服务名：just run-test-tcc mcp
run-test-tcc s=service: (_check_service s)
    cd backend && v -new-compiler -cc tcc -no-retry-compilation -d trace_orm {{ if s == "all" { "" } else { "-d " + s } }} run ./main -f etc/config_dev.toml

# 编译到 backend/app（amd64）；可选服务名：just build-amd64 fms
build-amd64 s=service: (_check_service s)
    cd backend && time v -b amd64 -no-prealloc -new-compiler -stats -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（tcc）；可选服务名：just build-tcc fms
build-tcc s=service: (_check_service s)
    cd backend && time v -no-prealloc -new-compiler -stats -cc tcc -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（amd64 + ownership）；可选服务名：just build-amd64-owership fms
build-amd64-owership s=service: (_check_service s)
    cd backend && time v -b amd64 -ownership -autofree -gc none -no-prealloc -new-compiler -stats -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（tcc + V 自带 GC）；可选服务名：just build-tcc-vgc fms
build-tcc-vgc s=service: (_check_service s)
    cd backend && time v -autofree -gc vgc -no-prealloc -new-compiler -stats -cc tcc -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 编译到 backend/app（amd64 + V 自带 GC）；可选服务名：just build-amd64-vgc fms
build-amd64-vgc s=service: (_check_service s)
    cd backend && time v -b amd64 -autofree -gc vgc -no-prealloc -new-compiler -stats -no-retry-compilation {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 生产编译（默认 C 后端）；可选服务名：just build-prod-c pay
build-prod-c s=service: (_check_service s)
    cd backend && time v -ownership -new-compiler -prod -stats {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# 生产编译（amd64）；可选服务名：just build-prod-amd64 pay
build-prod-amd64 s=service: (_check_service s)
    cd backend && time v -b amd64 -ownership -new-compiler -prod -stats {{ if s == "all" { "" } else { "-d " + s } }} -o app ./main

# ─── 前端 ──────────────────────────────────────────
get-frontend:
    cd frontend && flutter pub get

analyze-frontend:
    cd frontend && melos analyze

test-frontend:
    cd frontend && melos test

gen-frontend:
    cd frontend && melos gen

# web 映射到 web-server；传入 linux、chrome 等值时直接作为 Flutter 设备使用。
run-platform target="web" port="51000":
    cd frontend/apps/platform-pc && flutter run -d {{ if target == "web" { "web-server" } else { target } }}{{ if target == "web" { " --web-port " + port } else { "" } }}

run-business target="web" port="51002":
    cd frontend/apps/business-pc && flutter run -d {{ if target == "web" { "web-server" } else { target } }}{{ if target == "web" { " --web-port " + port } else { "" } }}

run-app target="web" port="51003":
    cd frontend/apps/app-miniapp && flutter run -d {{ if target == "web" { "web-server" } else { target } }}{{ if target == "web" { " --web-port " + port } else { "" } }}

# 一条命令并行拉起全部 3 个原型 + 静态入口页（51090）。
# 打开 http://localhost:51090 一页点进所有端；Ctrl-C 全部停止。
# 覆盖示例：just run-apps chrome 51010 51099

# 也可用环境变量：DEVICE=chrome BASE_PORT=51010 HUB_PORT=51099 just run-apps
run-apps device=env_var_or_default("DEVICE", "web-server") base_port=env_var_or_default("BASE_PORT", "51000") hub_port=env_var_or_default("HUB_PORT", "51090"):
    DEVICE={{ device }} BASE_PORT={{ base_port }} HUB_PORT={{ hub_port }} ./frontend/tools/dev_all.sh

# 构建目标写在命令末尾，如：just build-platform web、just build-app apk、just build-app aab。
build-platform target="web":
    cd frontend/apps/platform-pc && flutter build {{ target }}

build-business target="web":
    cd frontend/apps/business-pc && flutter build {{ target }}

build-app target="web":
    cd frontend/apps/app-miniapp && flutter build {{ if target == "aab" { "appbundle" } else { target } }}{{ if target == "web" { "" } else { " --no-tree-shake-icons" } }}

# 依次构建全部 3 个前端 Web 产物。
build-frontend:
    just build-platform web
    just build-business web
    just build-app web

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9
