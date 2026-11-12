# 小程序启动器

客户首页通过下拉打开小程序选择页。启动器只负责展示入口、维护“最近使用 /
我的小程序”视图，以及把选中的 `MiniProgramLauncherItem` 上报给宿主。

具体小程序路由由 IM 宿主根据 `item.id` 决定，启动器不直接依赖 ATS、HR、
商户、伙伴或平台模块。

- `miniapp_picker_page.dart`：选择页和小程序目录。
- `miniapp_collection_page.dart`：最近使用 / 我的小程序集合页。
- `miniapp_launcher_item.dart`：公开启动项模型和已知入口标识。
- `launcher_widgets.dart`：搜索栏、分组标题、入口网格和底部操作栏。
