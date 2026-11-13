# 小程序资源归属

每个小程序独立维护自己的页面、图片、字体和翻译，避免资源在应用根目录或
其他小程序目录之间混放。

- 图片和字体：`<mini-program>/assets/`
- 翻译：`<mini-program>/l10n/`
- 小程序之间共用的外壳与通用翻译：`common/`

`common/l10n/miniapp_localizations.dart` 只负责合并各小程序的翻译表，供公共
导航栏、操作菜单等渲染时查询，不保存业务小程序的翻译内容。

小程序采用自定义导航：公共层只固定右上角 `MiniProgramCapsuleOverlay` 胶囊，
不再提供整条共享顶栏。页面标题、返回和首屏 Hero 由各小程序自行渲染；默认首屏
及自定义页头必须通过 `MiniProgramCapsuleOverlay.reservedRight` /
`reservedHeight` 留出胶囊安全区，避免按钮被遮挡。

当前目录包含企业直聘、人事、商户、伙伴、平台管理和 Tospino 商城。Tospino
直接接入 Tospino 安卓端使用的真实接口：分类、商品搜索、商品详情、购物车、
收藏、地址、SaleInfo、订单提交、订单列表/详情和买家资料。公共浏览使用 Basic
鉴权；购物车和订单等账户能力使用 Tospino OAuth 登录后的 access token，并由
`SharedPreferences` 持久化。

Tospino API 客户端位于 `lib/miniapp/tospino/api/tospino_api.dart`。默认连接与安卓
debug 构建一致的测试环境，可通过以下参数切换正式环境和预置令牌：

```bash
flutter run \
  --dart-define=TOSPINO_API_BASE_URL=https://gh2capi.tospino.com.gh \
  --dart-define=TOSPINO_SSO_BASE_URL=https://oauthapi.tospino.com.gh
```

`TOSPINO_ACCESS_TOKEN` 和 `TOSPINO_TOKEN_TYPE` 可用于自动化或联调环境直接注入
已有会话；正常账户流程应使用小程序内的 Tospino 登录页。

新增资源时，应放入使用该资源的小程序目录，并在应用的 `pubspec.yaml`
资源声明中登记路径。新增或迁移图片后运行
`flutter test test/resource_ownership_test.dart` 检查归属。
