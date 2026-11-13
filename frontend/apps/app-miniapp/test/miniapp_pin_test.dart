import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/miniapp_pin.dart';

void main() {
  test('只保存一个小程序，后钉住的小程序会替换前一个', () async {
    final store = _MemoryMiniProgramPinStore();
    final controller = MiniProgramPinController(store: store);
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.pin('ats');
    expect(controller.pinnedId, 'ats');
    expect(store.pinnedId, 'ats');

    await controller.pin('hr');
    expect(controller.pinnedId, 'hr');
    expect(store.pinnedId, 'hr');
    expect(controller.isPinned('ats'), isFalse);

    await controller.unpin();
    expect(controller.pinnedId, isNull);
    expect(store.pinnedId, isNull);
  });

  testWidgets('长按退出按钮切换图钉，重新启动后默认进入钉住的小程序', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = _MemoryMiniProgramPinStore();
    final firstController = MiniProgramPinController(store: store);
    await firstController.initialize();
    await tester.pumpWidget(
      BusinessApp(miniProgramPinController: firstController),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mini-program-picker-ats')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mini-program-close-icon')), findsOneWidget);
    await tester.longPress(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mini-program-pin-icon')), findsOneWidget);
    expect(find.byKey(const Key('mini-program-close-icon')), findsNothing);
    expect(store.pinnedId, 'ats');

    await tester.pumpWidget(const SizedBox.shrink());
    firstController.dispose();

    final secondController = MiniProgramPinController(store: store);
    await secondController.initialize();
    addTearDown(secondController.dispose);
    await tester.pumpWidget(
      BusinessApp(miniProgramPinController: secondController),
    );
    await tester.pumpAndSettle();

    expect(find.text('搜索岗位或关键词'), findsOneWidget);
    expect(find.byKey(const Key('mini-program-pin-icon')), findsOneWidget);

    await tester.longPress(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mini-program-close-icon')), findsOneWidget);
    expect(store.pinnedId, isNull);
  });
}

class _MemoryMiniProgramPinStore implements MiniProgramPinStore {
  String? pinnedId;

  @override
  Future<String?> readPinnedId() async => pinnedId;

  @override
  Future<void> writePinnedId(String? id) async {
    pinnedId = id;
  }
}
