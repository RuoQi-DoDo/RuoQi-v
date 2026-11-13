import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_capsule_overlay.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_navigation_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_controller.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_models.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_repository.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_routes.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/pages/team_pages.dart';

void main() {
  testWidgets('存在系统状态栏时不再绘制模拟状态栏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(padding: const EdgeInsets.only(top: 24)),
            child: child!,
          );
        },
        home: const HrMiniProgram(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('9:41'), findsNothing);
    expect(find.byTooltip('小程序菜单'), findsOneWidget);
    expect(find.byTooltip('退出小程序'), findsOneWidget);
  });

  testWidgets('HR 小程序默认展示完整的静态首页', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HrMiniProgram()));
    await tester.pumpAndSettle();

    expect(find.text('林知夏'), findsOneWidget);
    expect(find.text('今日工作中'), findsOneWidget);
    expect(find.text('4 个申请等待你审批'), findsOneWidget);
    expect(find.text('发起请假'), findsOneWidget);
    expect(find.text('我的考勤'), findsOneWidget);
    expect(find.text('工资单'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.byKey(const Key('hr-tab-团队')), findsOneWidget);
    expect(find.byTooltip('退出小程序'), findsOneWidget);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byType(MiniProgramNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
    expect(HrConfig.useMockData, isTrue);
  });

  testWidgets('客户小程序选择页可以打开人事小程序', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mini-program-picker-hr')));
    await tester.pumpAndSettle();

    expect(find.text('人事工作台'), findsOneWidget);
    expect(find.text('林知夏'), findsOneWidget);
    expect(find.text('搜索岗位或关键词'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HR 全部路由均可构建', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = HrAppController();
    addTearDown(controller.dispose);
    expect(HrRoute.values.length, 28);

    for (final route in HrRoute.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 760,
              child: HrPageRouter.build(route, controller),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'HR 页面 ${route.name} 构建失败',
      );
    }
  });

  testWidgets('首页打卡会进入独立打卡页面并隐藏底栏', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HrMiniProgram()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hr-punch-button')));
    await tester.pump();

    expect(find.text('上下班打卡'), findsWidgets);
    expect(find.byKey(const Key('hr-tab-首页')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('确认下班打卡'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('确认下班打卡'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('审批通过后会从待办中移除', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = HrAppController();
    addTearDown(controller.dispose);
    final before = controller.approvals.length;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HrApprovalsPage(controller: controller)),
      ),
    );
    await tester.tap(find.text('通过').first);
    await tester.pumpAndSettle();

    expect(controller.approvals.length, before - 1);
    expect(find.text('撤销'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('静态模式下请假与审批状态可变化', () async {
    final controller = HrAppController();
    addTearDown(controller.dispose);
    final initialLeaves = controller.leaveRequests.length;
    final firstApproval = controller.approvals.first;

    await controller.submitLeave(
      type: '年假',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      reason: '家庭事务',
      halfDay: false,
    );
    await controller.decideApproval(firstApproval, approve: true);

    expect(controller.leaveRequests.length, initialLeaves + 1);
    expect(controller.leaveRequests.first.status, HrLeaveStatus.pending);
    expect(
      controller.approvals.any((item) => item.id == firstApproval.id),
      isFalse,
    );

    await controller.undoLastDecision();
    expect(
      controller.approvals.any((item) => item.id == firstApproval.id),
      isTrue,
    );
  });
}
