# IM 聊天首页

此目录只保留 IM 聊天业务。`im_chat_page.dart` 提供登录后的 `ImChatPage`，
页面通过 `scrollController` 使用公共宿主的首页滚动控制器。未登录启动流程由
`main.dart` 的 `BusinessApp` 统一门禁：欢迎页 → 登录页 → 业务首页；已登录时
直接进入 IM 首页，退出登录后回到登录页。登录页沿用 WhatsApp 手机号验证层级，
由 `pages/auth/phone_login_page.dart` 提供国家/地区、区号和手机号输入，
`phone_country_picker_page.dart` 提供可搜索的国家/地区列表。号码提交后进入
`phone_verification_page.dart`，验证码通过后才进入业务首页；手机号与验证码输入
都会自动聚焦并唤起数字键盘。后端短信投递尚未完成前，演示验证码为 `123456`。

`im_welcome_page.dart` 负责欢迎页、隐私政策、服务条款、无障碍说明和菜单；
公共页面的 `pages/common/app_language_page.dart` 展示完整语言目录，其中只有
简体中文和 English 可切换，其余语言保留展示但置灰并提示暂未开放。欢迎页和
“设置 → 界面与显示 → 多语言”共用这个弹窗式入口。
语言选择直接更新 `BusinessThemeController.locale`，欢迎页、语言页、聊天列表及
语义标签会同步切换中英文。`im_localizations.dart` 汇总页面文案辅助方法，
`im_style.dart` 保存 IM 欢迎页使用的高对比色板。

通讯录、发现、我的、设置、登录及小程序交互分别位于 `pages/` 的公共模块，
不依赖此目录。`main.dart` 将 IM 作为当前 `BusinessHostPage.homeBuilder`；
更换业务时替换首页构建器，公共页面与导航可继续复用。
