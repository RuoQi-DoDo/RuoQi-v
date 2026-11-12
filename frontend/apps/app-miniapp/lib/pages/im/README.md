# IM 聊天首页

此目录只保留 IM 聊天业务。`im_chat_page.dart` 提供 `ImChatPage`，通过
`scrollController` 使用公共宿主的首页滚动控制器。

通讯录、发现、我的、设置、登录及小程序交互分别位于 `pages/` 的公共模块，
不依赖此目录。`main.dart` 将 IM 作为当前 `BusinessHostPage.homeBuilder`；
更换业务时替换首页构建器，公共页面与导航可继续复用。
