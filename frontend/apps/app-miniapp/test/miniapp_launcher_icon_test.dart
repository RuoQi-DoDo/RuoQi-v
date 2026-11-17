import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_launcher_item.dart';

void main() {
  testWidgets('图片资源和矢量图标均使用圆形裁剪', (tester) async {
    const assetItem = MiniProgramLauncherItem(
      id: 'tospino',
      label: 'Tospino',
      icon: Icons.storefront_rounded,
      color: Colors.teal,
      assetPath: tospinoMiniProgramIconAsset,
    );
    const iconItem = MiniProgramLauncherItem(
      id: 'ats',
      label: '企业直聘',
      icon: Icons.work_outline_rounded,
      color: Colors.green,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            MiniProgramLauncherIcon(item: assetItem, size: 38),
            MiniProgramLauncherIcon(item: iconItem, size: 38),
          ],
        ),
      ),
    );

    final iconContainers = tester.widgetList<Container>(find.byType(Container));
    expect(iconContainers, hasLength(2));
    for (final container in iconContainers) {
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(container.clipBehavior, Clip.antiAlias);
    }
  });
}
