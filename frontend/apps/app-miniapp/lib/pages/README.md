# 业务首页与公共页面

`pages/` 按业务首页和可复用功能划分。各页面是独立 Dart 库，可以单独作为路由
运行；通过 `pages/index.dart` 统一导出。

- `host/`：公共业务宿主，组合业务首页、通讯录、发现、我的和小程序选择页。
- `im/`：当前业务首页，仅提供 IM 聊天列表。
- `contacts/`：公共通讯录。
- `discover/`：公共发现页。
- `profile/`：公共我的页面，默认进入公共设置。
- `settings/`：公共设置，可注入退出登录行为及登录页面。
- `auth/`：公共登录页。
- `common/`：公共页面使用的主题、文案与列表组件。
- `account/`：公共账号安全、密码、手机/邮箱绑定、关联账号、设备和日志。
- `display/`：公共界面与显示（主题模式、字体大小、中英文、屏幕方向）。

`BusinessAppFrame` 管理全局主题、语言、字体与账号状态；`BusinessHostPage`
管理公共导航及小程序交互。两层均不依赖 IM。当前 `main.dart` 只在业务首页
构建器中选择 `ImChatPage`。使用默认应用入口时，替换
`BusinessApp(homeBuilder: ..., homeLabel: ...)` 即可；自行组合应用时如下：

```dart
BusinessAppFrame(
  title: '新业务',
  home: (_) => BusinessHostPage(
    homeLabel: '首页',
    homeBuilder: (context, scrollController) => NewBusinessHomePage(
      scrollController: scrollController,
    ),
  ),
)
```

首页将宿主提供的 `ScrollController` 连接到主滚动区域，宿主即可在首页滚动到
顶部时响应下拉小程序手势。切换公共页面和打开子路由会保留业务首页状态。
通讯录、发现与我的也可以直接作为 `MaterialApp.home` 或普通路由运行。当前
宿主保留各页自己的 Scaffold 和主题；其他容器需要嵌入页面内容时，可选用
`embedded: true`。

宿主和设置页的 `loginBuilder` 可指定登出后的登录路由；如果业务负责会话清理
和导航，可用 `onLogout` 接管确认登出后的动作。

显示状态作用于所有路由及小程序内部 Navigator；切换主题、语言和字体大小不
清空页面栈。当前提供简体中文、English 和跟随系统，业务数据保留原文。
屏幕方向通过 `SystemChrome.setPreferredOrientations` 请求，由运行平台执行。
设置状态及账号安全演示数据保存在当前运行内，安全操作未连接真实认证后端。

小程序页面统一放在 `lib/miniapp/`，由公共宿主打开，与业务首页实现独立。
平台旧账号页面路径保留兼容导出。
