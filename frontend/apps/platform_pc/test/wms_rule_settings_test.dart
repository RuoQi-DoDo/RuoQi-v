import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/main.dart';
import 'package:ruoqi_platform_pc/wms_pages/index.dart';

void main() {
  Future<void> openWms(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    WmsConsoleDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
  }

  testWidgets('WMS 规则控制台展示四类规则与默认约束页', (tester) async {
    await openWms(tester);

    expect(find.text('WMS管理'), findsOneWidget);
    for (final category in ['基础规则', '入库规则', '库内操作', '出库规则']) {
      expect(find.text(category), findsOneWidget);
    }
    expect(find.text('规则设置 / 基础规则 / 约束设置'), findsOneWidget);
    final breadcrumb = tester.widget<Text>(find.text('规则设置 / 基础规则 / 约束设置'));
    expect(breadcrumb.style?.fontSize, 11);
    expect(find.text('约束设置'), findsWidgets);
    expect(find.text('基础信息'), findsWidgets);
    expect(find.text('新建'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('WMS 编辑规则在内容区打开子视图并保留侧栏', (tester) async {
    await openWms(tester);

    await tester.tap(find.text('入库规则'));
    await tester.pumpAndSettle();
    expect(find.text('规则设置 / 入库规则 / 货位推荐规则'), findsOneWidget);

    await tester.tap(find.text('质检规则'));
    await tester.pumpAndSettle();
    expect(find.text('规则设置 / 入库规则 / 质检规则'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '编辑').first);
    await tester.pumpAndSettle();
    expect(find.byType(WmsRuleEditorView), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('编辑质检规则'), findsOneWidget);
    expect(find.text('入库规则'), findsOneWidget);
    expect(find.text('质检设置'), findsOneWidget);
    expect(find.text('质检位置'), findsOneWidget);
    expect(find.text('收货前'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.byType(WmsRuleEditorView), findsNothing);
    expect(find.text('规则设置 / 入库规则 / 质检规则'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('WMS 空页面可新建规则并即时回到列表', (tester) async {
    await openWms(tester);

    await tester.tap(find.text('序列号解析规则'));
    await tester.pumpAndSettle();
    expect(find.text('暂无规则配置'), findsOneWidget);

    await tester.tap(find.text('新建规则'));
    await tester.pumpAndSettle();
    expect(find.byType(WmsRuleEditorView), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('新建序列号解析规则'), findsOneWidget);
    expect(find.text('规则条件设置'), findsOneWidget);
    expect(find.text('序列号位数解析设置'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('wms-rule-name')),
      '食品序列号解析',
    );
    await tester.tap(find.widgetWithText(FilledButton, '确定'));
    await tester.pumpAndSettle();

    expect(find.text('食品序列号解析'), findsWidgets);
    expect(find.text('暂无规则配置'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('WMS 表格规则展示与截图一致的核心列', (tester) async {
    await openWms(tester);

    await tester.tap(find.text('波次拣货人分配规则'));
    await tester.pumpAndSettle();
    for (final label in ['规则名称', '规则类型', '仓库', '优先级', '状态', '默认规则']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('指定人员拣货规则'), findsOneWidget);
    expect(find.text('最少任务优先'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('单据编码规则使用左侧单据清单和右侧编码配置', (tester) async {
    await openWms(tester);

    await tester.tap(find.text('单据编码规则'));
    await tester.pumpAndSettle();
    expect(find.byType(WmsCodingRulesPage), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('单据清单'), findsOneWidget);
    expect(find.text('基础信息'), findsOneWidget);
    expect(find.text('收货管理'), findsOneWidget);
    expect(find.text('供应商合同编码规则'), findsOneWidget);
    expect(find.text('发货人编码规则'), findsOneWidget);
    expect(find.text('快递管理'), findsWidgets);
    expect(find.textContaining('流水号字符集'), findsOneWidget);
    expect(find.textContaining('模块菜单ID'), findsOneWidget);
    expect(find.text('迁移状态'), findsOneWidget);

    await tester.tap(find.text('发货人编码规则'));
    await tester.pumpAndSettle();
    final nameField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('wms-coding-name')),
    );
    expect(nameField.controller!.text, '发货人编码规则');

    await tester.tap(find.byKey(const ValueKey('wms-coding-charset')));
    await tester.pumpAndSettle();
    expect(find.text('[A-Z] 仅大写字母'), findsOneWidget);
    await tester.tap(find.text('[A-Z] 仅大写字母'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加同级'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('新建单据编码规则'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.text('发货人编码规则'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('平台工作台增加 WMS 配置入口', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    expect(find.text('WMS管理'), findsOneWidget);
    await tester.tap(find.text('WMS管理'));
    await tester.pumpAndSettle();

    expect(find.text('WMS管理'), findsNWidgets(2));
    expect(find.text('规则设置 / 基础规则 / 约束设置'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
