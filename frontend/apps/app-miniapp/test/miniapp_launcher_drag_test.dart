import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_launcher_item.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_library_controller.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_picker_page.dart';

const _ats = MiniProgramLauncherItem(
  id: 'ats',
  label: '企业直聘',
  icon: Icons.work_outline,
  color: Colors.teal,
);
const _hr = MiniProgramLauncherItem(
  id: 'hr',
  label: '人事',
  icon: Icons.badge_outlined,
  color: Colors.deepOrange,
);
const _files = MiniProgramLauncherItem(
  id: 'file-assistant',
  label: '文件助手',
  icon: Icons.folder_outlined,
  color: Colors.blue,
);

void main() {
  testWidgets('长按显示微信式操作区，取消拖拽不会启动或移除小程序', (tester) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    var opens = 0;
    var exits = 0;
    await _pumpPicker(
      tester,
      controller,
      onOpen: (_) => opens++,
      onExit: () => exits++,
    );

    final gesture = await _startDrag(tester, 'recent', 'file-assistant');
    expect(find.byKey(const Key('mini-program-drop-add')), findsOneWidget);
    expect(find.byKey(const Key('mini-program-drop-delete')), findsOneWidget);
    await gesture.moveTo(
      tester.getCenter(find.byKey(const Key('mini-program-drop-delete'))),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(controller.recentItems.map((item) => item.id), [
      'ats',
      'hr',
      'file-assistant',
    ]);
    expect(controller.myItems.map((item) => item.id), ['ats', 'hr']);
    expect(opens, 0);
    expect(exits, 0);
    expect(find.byKey(const Key('mini-program-drop-delete')), findsNothing);
    await tester.tap(_tile('recent', 'file-assistant'));
    await tester.pumpAndSettle();
    expect(opens, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('最近使用拖到添加区会加入我的小程序且不重复添加', (tester) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pumpPicker(tester, controller);

    await _drop(tester, 'recent', 'file-assistant', 'mini-program-drop-add');
    expect(
      controller.myItems.where((item) => item.id == 'file-assistant'),
      hasLength(1),
    );
    expect(
      controller.recentItems.any((item) => item.id == 'file-assistant'),
      isTrue,
    );
    await _drop(tester, 'recent', 'file-assistant', 'mini-program-drop-add');
    expect(
      controller.myItems.where((item) => item.id == 'file-assistant'),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('删除最近使用只移除历史，不删除我的小程序', (tester) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    var exits = 0;
    await _pumpPicker(tester, controller, onExit: () => exits++);

    await _drop(tester, 'recent', 'ats', 'mini-program-drop-delete');
    expect(controller.recentItems.any((item) => item.id == 'ats'), isFalse);
    expect(controller.myItems.any((item) => item.id == 'ats'), isTrue);
    expect(_tile('recent', 'ats'), findsNothing);
    expect(_tile('mine', 'ats'), findsOneWidget);
    expect(exits, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('我的小程序集合支持拖拽排序和移除，最近记录保持', (tester) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pumpPicker(tester, controller);
    await tester.tap(find.text('我的小程序'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('mini-program-collection-mine')),
      findsOneWidget,
    );

    final gesture = await _startDrag(tester, 'mine', 'ats');
    await gesture.moveTo(tester.getCenter(_tile('mine', 'hr')));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.myItems.map((item) => item.id), ['hr', 'ats']);

    await _drop(tester, 'mine', 'ats', 'mini-program-drop-delete');
    expect(controller.myItems.map((item) => item.id), ['hr']);
    expect(controller.recentItems.any((item) => item.id == 'ats'), isTrue);
    expect(_tile('mine', 'ats'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('关闭并重新打开宿主小程序面板后保留删除结果', (tester) async {
    _phone(tester);
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await _openPicker(tester);
    final controller = MiniProgramLibraryScope.maybeOf(
      tester.element(find.byKey(const Key('customer-mini-program-picker'))),
    )!;
    await _drop(tester, 'recent', 'file-assistant', 'mini-program-drop-delete');
    expect(
      controller.recentItems.any((item) => item.id == 'file-assistant'),
      isFalse,
    );
    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -90),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer-mini-program-picker')), findsNothing);

    await _openPicker(tester);
    expect(_tile('recent', 'file-assistant'), findsNothing);
    expect(
      controller.recentItems.any((item) => item.id == 'file-assistant'),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('小屏深色英文及放大字体下拖拽删除区无布局异常', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BusinessAppFrame(
        title: 'test',
        home: (_) => MiniProgramPickerPage(
          onOpen: (_) {},
          onCloseDragStart: (_) {},
          onCloseDragUpdate: (_) {},
          onCloseDragEnd: (_) {},
          onCloseDragCancel: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(MiniProgramPickerPage));
    final settings = BusinessThemeScope.of(context);
    final controller = MiniProgramLibraryScope.maybeOf(context)!;
    settings.setMode(ThemeMode.dark);
    settings.setLocale(const Locale('en'));
    settings.setFontScale(1.3);
    await tester.pumpAndSettle();

    final gesture = await _startDrag(tester, 'recent', 'file-assistant');
    await gesture.moveTo(
      tester.getCenter(find.byKey(const Key('mini-program-drop-delete'))),
    );
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.text('Release to delete'), findsOneWidget);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(
      controller.recentItems.any((item) => item.id == 'file-assistant'),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}

MiniProgramLibraryController _controller() => MiniProgramLibraryController(
  recentItems: const [_ats, _hr, _files],
  myItems: const [_ats, _hr],
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(414, 896);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _pumpPicker(
  WidgetTester tester,
  MiniProgramLibraryController controller, {
  ValueChanged<MiniProgramLauncherItem>? onOpen,
  VoidCallback? onExit,
}) async {
  _phone(tester);
  await tester.pumpWidget(
    MiniProgramLibraryScope(
      controller: controller,
      child: MaterialApp(
        home: MiniProgramPickerPage(
          onOpen: onOpen ?? (_) {},
          onCloseDragStart: (_) => onExit?.call(),
          onCloseDragUpdate: (_) {},
          onCloseDragEnd: (_) {},
          onCloseDragCancel: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _tile(String list, String id) =>
    find.byKey(Key('mini-program-drag-$list-$id'));

Future<TestGesture> _startDrag(
  WidgetTester tester,
  String list,
  String id,
) async {
  final tile = _tile(list, id);
  await tester.ensureVisible(tile);
  final gesture = await tester.startGesture(tester.getCenter(tile));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 80));
  await gesture.moveBy(const Offset(4, 4));
  await tester.pump(const Duration(milliseconds: 120));
  return gesture;
}

Future<void> _drop(
  WidgetTester tester,
  String list,
  String id,
  String targetKey,
) async {
  final gesture = await _startDrag(tester, list, id);
  await gesture.moveTo(tester.getCenter(find.byKey(Key(targetKey))));
  await tester.pump(const Duration(milliseconds: 120));
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _openPicker(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const Key('customer-home-scroll')),
    const Offset(0, 320),
  );
  await tester.pumpAndSettle();
}
