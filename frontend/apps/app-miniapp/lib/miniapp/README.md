# 小程序资源归属

每个小程序独立维护自己的页面、图片、字体和翻译，避免资源在应用根目录或
其他小程序目录之间混放。

- 图片和字体：`<mini-program>/assets/`
- 翻译：`<mini-program>/l10n/`
- 小程序之间共用的外壳与通用翻译：`common/`

`common/l10n/miniapp_localizations.dart` 只负责合并各小程序的翻译表，供公共
导航栏、操作菜单等渲染时查询，不保存业务小程序的翻译内容。

新增资源时，应放入使用该资源的小程序目录，并在应用的 `pubspec.yaml`
资源声明中登记路径。新增或迁移图片后运行
`flutter test test/resource_ownership_test.dart` 检查归属。
