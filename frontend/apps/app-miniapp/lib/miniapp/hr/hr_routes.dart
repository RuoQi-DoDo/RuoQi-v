enum HrRoute {
  signIn(title: '员工登录', tabIndex: 0),
  punch(title: '上下班打卡', tabIndex: 0),
  faceCheck(title: '人脸核验', tabIndex: 0),
  home(title: '人事工作台', tabIndex: 0),
  attendance(title: '我的考勤', tabIndex: 1),
  leave(title: '休假', tabIndex: 1),
  leaveApply(title: '发起请假', tabIndex: 1),
  leaveAllocation(title: '额度追加', tabIndex: 1),
  correction(title: '补卡申请', tabIndex: 1),
  requests(title: '申请中心', tabIndex: 2),
  requestCompose(title: '新建申请', tabIndex: 2),
  requestShift(title: '调班申请', tabIndex: 2),
  requestWorkType(title: '办公方式申请', tabIndex: 2),
  requestAsset(title: '资产申请', tabIndex: 2),
  requestReimburse(title: '费用报销', tabIndex: 2),
  helpdesk(title: '员工服务台', tabIndex: 2),
  payslips(title: '工资单', tabIndex: 2),
  payslipDetail(title: '工资明细', tabIndex: 2),
  approvals(title: '审批中心', tabIndex: 3),
  team(title: '我的团队', tabIndex: 3),
  directory(title: '企业通讯录', tabIndex: 3),
  announcements(title: '公司公告', tabIndex: 0),
  announcementDetail(title: '公告详情', tabIndex: 0),
  notifications(title: '消息通知', tabIndex: 0),
  me(title: '我的', tabIndex: 4),
  personalInfo(title: '个人信息', tabIndex: 4),
  faceEnrolment(title: '人脸录入', tabIndex: 4),
  settings(title: '设置', tabIndex: 4);

  const HrRoute({required this.title, required this.tabIndex});

  final String title;
  final int tabIndex;

  bool get isTabRoot => switch (this) {
    HrRoute.home ||
    HrRoute.attendance ||
    HrRoute.requests ||
    HrRoute.team ||
    HrRoute.me => true,
    _ => false,
  };

  bool get showsBottomNavigation =>
      this != HrRoute.signIn &&
      this != HrRoute.punch &&
      this != HrRoute.faceCheck;
}

class HrTabDestination {
  const HrTabDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final Object icon;
  final HrRoute route;
}
