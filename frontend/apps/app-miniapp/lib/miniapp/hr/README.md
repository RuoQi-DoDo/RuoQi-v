# HR 小程序

参考 `horilla-hr-mobile` 的信息架构实现，页面包括：

- 账号：服务器地址、员工登录与切换账号
- 首页：打卡入口、审批提醒、快捷入口、今日休假与最新公告
- 打卡：独立打卡页、定位信息、工时进度与人脸核验
- 时间：月度考勤、周工时、考勤明细、休假额度、请假与补卡
- 申请：调班、办公方式、费用报销、资产申请、员工服务台与工资单
- 团队：成员今日状态、审批中心、排班风险与通讯录
- 我的：个人信息、人脸录入、公告、通知、设置与数据源状态

## 数据模式

默认固定使用 `HrMockData`，所有页面无需后端即可展示和交互。

真实 Horilla API 边界位于 `../../api/hr/hr_api.dart`，通过 `HrRepository` 与页面隔离。
切换到远端仓库：

```bash
flutter run \
  --dart-define=HR_USE_MOCK_DATA=false \
  --dart-define=HR_API_BASE_URL=https://your-horilla.example/api/v1
```

也可以直接向 `HrMiniProgram(repository: ...)` 注入自定义 `HrRepository`。
未配置 token provider 的默认远端客户端不会自动注入鉴权头，实际接入时应传入
`RuoQiNetworkClient` 对应的 `AuthTokenProvider`。
