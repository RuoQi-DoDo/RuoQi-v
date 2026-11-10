# pages/im 业务组

这里承载微信式 IM 宿主主页及其本地页面：

- `im_home_page.dart`：IM 页面库和小程序交互状态。
- `im_host_page.dart`：聊天首页、下拉打开小程序选择页及业务入口。
- `contacts_page.dart` / `discover_page.dart` / `me_page.dart`：
  通讯录、发现、我的页面。
- `settings_page.dart`：设置与主题切换。
- `login_page.dart`：IM 业务组登录页。

IM 业务组默认作为业务 App 的主页面，也是当前唯一直接持有小程序选择页的
home。业务组由 `web/index.html` 中的 `RQ_DEFAULT_BUSINESS_GROUP` 选择，
也可以通过 `?group=im|ats|hr|merchant|partner|platform` 覆盖。
