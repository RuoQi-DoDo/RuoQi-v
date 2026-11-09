# wms_pages

按一级菜单划分业务模块，再按页面建立目录。页面入口统一使用
`<module>/<page>/index.dart`，模块内复用的模型和子视图与页面放在同一目录。

| 目录 | 内容 |
| --- | --- |
| `rule_module/rule_settings_page/` | 规则设置、规则编辑、单据编码规则和规则模型 |
| `outbound_module/outbound_operation_page/` | 出库作业 |
| `inbound_module/inbound_operation_page/` | 入库作业 |
| `in_warehouse_module/in_warehouse_operation_page/` | 仓内作业 |
| `shared/` | 作业模块共用的页面组件与展示模型 |

- `wms_console_dialog.dart`：WMS 控制台入口、一级菜单和页面切换。
- `index.dart`：WMS 页面对外统一导出。
