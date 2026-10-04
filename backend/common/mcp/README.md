# mcp

Vendored copy of V's standard-library `mcp` module, so the RuoQi backend can mount
the MCP server on its **existing veb listener/port** instead of running a second
loopback listener.

Location: `backend/common/mcp/` (imported as `common.mcp`), mirroring `common/api`.

## Provenance

- Source: `vlib/mcp` from V 0.5.2 (`/Applications/v/vlib/mcp`).
- Files vendored: `mcp.v`, `server.v` (production code only; tests omitted).
- Module name: `mcp` (same as upstream); imported here as `common.mcp`.

## Changes vs. upstream

Only one:

- `Server.handle_http_request(req http.Request) http.Response` is now `pub`, so a
  host can dispatch a single request in-process
  (see `backend/route/route_base_mcp.v`).

No protocol logic was changed.

## Updating

When upgrading V, re-copy `vlib/mcp/mcp.v` and `vlib/mcp/server.v` here and
re-apply the change above.
