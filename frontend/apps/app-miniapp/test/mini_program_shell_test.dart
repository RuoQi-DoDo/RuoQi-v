import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/miniapp_shell.dart';

void main() {
  testWidgets('公共胶囊使用固定半透明样式并响应两个操作', (tester) async {
    var moreTapCount = 0;
    var closeTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MiniProgramCapsule(
              onMore: () => moreTapCount++,
              onClose: () => closeTapCount++,
            ),
          ),
        ),
      ),
    );

    final capsule = find.byType(MiniProgramCapsule);
    expect(capsule, findsOneWidget);
    expect(
      tester.getSize(capsule),
      const Size(MiniProgramCapsule.width, MiniProgramCapsule.height),
    );

    final surface = tester.widget<Material>(
      find.descendant(of: capsule, matching: find.byType(Material)),
    );
    expect(surface.color, MiniProgramCapsule.surfaceColor);
    expect(surface.shape, isA<RoundedRectangleBorder>());

    await tester.tap(find.byTooltip('小程序菜单'));
    expect(moreTapCount, 1);

    await tester.tap(find.byTooltip('退出小程序'));
    expect(closeTapCount, 1);
  });

  testWidgets('点击三点打开微信式转发和功能面板', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MiniProgramShell(
          title: 'RuoQi 人事',
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('小程序菜单'));
    await tester.pumpAndSettle();

    expect(find.text('转发给'), findsOneWidget);
    expect(find.text('转发给朋友'), findsOneWidget);
    expect(find.text('分享到朋友圈'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('添加到\n我的小程序'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('重新进入\n小程序'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
    expect(find.text('分析'), findsNothing);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('转发给'), findsNothing);
  });
}
