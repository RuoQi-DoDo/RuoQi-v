# 业务组入口

`BusinessApp` 不再固定写死客户/IM 首页，而是在启动时解析当前业务组，
再用该业务组的 `home` Widget 作为 `MaterialApp.home`。

## Web 配置

编辑 `web/index.html`：

```js
const RQ_DEFAULT_BUSINESS_GROUP = 'im';
```

支持的值为：

- `im`：IM 宿主主页，包含下拉打开小程序选择页的交互。
- `ats`：企业直聘小程序首页。
- `hr`：人事小程序首页。
- `merchant`：商户首页。
- `partner`：伙伴首页。
- `platform`：平台账号中心首页。

无需重新构建也可通过 URL 临时覆盖：

```text
?group=merchant
```

## App 配置

Android / iOS 运行时使用：

```bash
flutter run --dart-define=BUSINESS_GROUP=merchant
```

没有配置或配置值无效时回退到 `im`。`BusinessGroupDefinition.hostsMiniPrograms`
标记该业务组的主页是否持有小程序宿主交互；当前为 IM 业务组。
