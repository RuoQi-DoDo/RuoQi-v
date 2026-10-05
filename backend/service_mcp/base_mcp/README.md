基础资料 MCP 服务

# base_mcp

把 `base_api` 的基础资料（货币 / 语言 / 国家地区 / 行政区划 / UTC 时区）暴露为
[MCP](https://modelcontextprotocol.io) 工具。MCP 服务随主应用一起启动，与 API 共用
同一个对外端口，通过路由前缀 `/mcp` 访问：`http://<host>:9009/mcp`。

位置：`backend/service_mcp/base_mcp/`（模块 `base_mcp`，工具子模块为
`service_mcp.base_mcp.currency` 等）。

内部实现：

- `mcp` 直接使用 V 标准库的 `vlib/mcp` 模块（其 `handle_http_request` 已导出）；
- `backend/main/mcp_start.v` 构建 MCP server，不监听任何端口；
- `backend/route/route_base_mcp.v` 的 `/mcp` 路由在同一个 veb 端口上**进程内**分发请求。

单端口、单 listener、无内部转发，也不需要单独部署进程。

## 工具

每个域提供 `find_all` / `create` / `update` / `delete` 四个工具，删除均为软删除
（`del_flag = -1`）。

| 域              | 工具前缀                |
| --------------- | ----------------------- |
| currency        | `base_currency_*`       |
| language        | `base_language_*`       |
| region          | `base_region_*`         |
| region_adm_div  | `base_region_adm_div_*` |
| utc             | `base_utc_*`            |

## 访问

启动主应用即可（MCP 随应用启动）：

```bash
just dev      # 开发模式
just test     # 或直接跑一次
```

MCP 端点：`http://localhost:9009/mcp`（Streamable HTTP）。

```bash
# 1) initialize，响应头里会带回 MCP-Session-Id
curl -si http://localhost:9009/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1"}}}'

# 2) 带上会话头调用 tools/list
curl -s http://localhost:9009/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'MCP-Session-Id: <上一步响应头里的值>' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
```

MCP 客户端配置（Streamable HTTP）：

```json
{
  "mcpServers": {
    "ruoqi-base": {
      "url": "http://localhost:9009/mcp"
    }
  }
}
```

## 约定

- 工具入参遵循 `base_api` 的 DTO 命名（V 侧 snake_case，JSON 侧 camelCase）。
- 每个域一个子模块（`currency` / `language` / `region` / `region_adm_div` / `utc`），
  一个工具一个 `*_logic.v`，分层顺序与项目 DDD 规范一致。
- 所有工具通过共享的 `&dbpool.DatabasePoolable` 访问数据库，与 API 服务使用同一连接池。

## 说明

- veb 与 MCP 共用同一个监听 socket，`/mcp` 由 veb 路由进程内调用
  `mcp.Server.handle_http_request`，没有额外端口或反代跳数。
- `mcp` 的 HTTP 传输沿用 vlib 实现：请求-响应模型，`GET` 返回当前已排队的
  SSE 事件并结束（不是长期连接）。
