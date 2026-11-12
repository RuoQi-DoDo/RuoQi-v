import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_launcher_item.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_library_controller.dart';

const _a = MiniProgramLauncherItem(
  id: 'a',
  label: 'A',
  icon: Icons.apps,
  color: Colors.teal,
  tileKey: Key('my-a'),
);
const _b = MiniProgramLauncherItem(
  id: 'b',
  label: 'B',
  icon: Icons.apps,
  color: Colors.blue,
);
const _c = MiniProgramLauncherItem(
  id: 'c',
  label: 'C',
  icon: Icons.apps,
  color: Colors.red,
);

void main() {
  test('initial lists deduplicate IDs and cannot be mutated externally', () {
    final recentInput = [_a, _b, _a];
    final controller = MiniProgramLibraryController(
      recentItems: recentInput,
      myItems: [_a, _a],
    );
    addTearDown(controller.dispose);
    recentInput.clear();
    expect(controller.recentItems.map((item) => item.id), ['a', 'b']);
    expect(controller.myItems.map((item) => item.id), ['a']);
    expect(() => controller.myItems.clear(), throwsUnsupportedError);
    expect(() => controller.recentItems.add(_c), throwsUnsupportedError);
    expect(controller.recentItems.first.tileKey, isNull);
  });

  test(
    'adding an existing My entry has no effect or duplicate notification',
    () {
      final controller = MiniProgramLibraryController(
        recentItems: [_a, _b],
        myItems: [_a],
      );
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);
      expect(controller.addToMy(_a), isFalse);
      expect(notifications, 0);
      expect(controller.addToMy(_b), isTrue);
      expect(controller.containsMy('b'), isTrue);
      expect(controller.myItems.map((item) => item.id), ['a', 'b']);
      expect(notifications, 1);
    },
  );

  test('restoring known My entries restores their stable tile keys', () {
    final controller = MiniProgramLibraryController(
      recentItems: const [],
      myItems: const [],
    );
    addTearDown(controller.dispose);
    const item = MiniProgramLauncherItem(
      id: MiniProgramLauncherIds.ats,
      label: '企业直聘',
      icon: Icons.work_outline,
      color: Colors.teal,
    );
    controller.addToMy(item);
    expect(
      controller.myItems.single.tileKey,
      const ValueKey('mini-program-picker-ats'),
    );
    controller.recordOpen(controller.myItems.single);
    expect(controller.recentItems.single.tileKey, isNull);
  });

  test('opening a removed recent entry restores it once at the front', () {
    final controller = MiniProgramLibraryController(
      recentItems: [_a, _b],
      myItems: [_a],
    );
    addTearDown(controller.dispose);
    controller.removeRecent('a');
    expect(controller.recentItems.map((item) => item.id), ['b']);
    controller.recordOpen(_a);
    controller.recordOpen(_a);
    expect(controller.recentItems.map((item) => item.id), ['a', 'b']);
    expect(controller.recentItems.first.tileKey, isNull);
    expect(controller.myItems.map((item) => item.id), ['a']);
    controller.recordOpen(_b);
    expect(controller.recentItems.map((item) => item.id), ['b', 'a']);
  });

  test('recent and My deletions affect only their own collection', () {
    final controller = MiniProgramLibraryController(
      recentItems: [_a, _b],
      myItems: [_a, _b],
    );
    addTearDown(controller.dispose);
    controller.removeRecent('a');
    expect(controller.containsMy('a'), isTrue);
    controller.removeFromMy('b');
    expect(controller.recentItems.map((item) => item.id), ['b']);
    expect(controller.myItems.map((item) => item.id), ['a']);
  });

  test('reordering persists in the chosen list and ignores invalid drops', () {
    final controller = MiniProgramLibraryController(
      recentItems: [_a, _b, _c],
      myItems: [_a, _b, _c],
    );
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.reorder(MiniProgramListKind.mine, 'a', 'c');
    expect(controller.myItems.map((item) => item.id), ['b', 'c', 'a']);
    expect(controller.recentItems.map((item) => item.id), ['a', 'b', 'c']);
    controller.reorder(MiniProgramListKind.mine, 'a', 'b');
    expect(controller.myItems.map((item) => item.id), ['a', 'b', 'c']);
    controller.reorder(MiniProgramListKind.recent, 'c', 'a');
    expect(controller.recentItems.map((item) => item.id), ['c', 'a', 'b']);
    expect(notifications, 3);
    controller.reorder(MiniProgramListKind.mine, 'a', 'a');
    controller.reorder(MiniProgramListKind.mine, 'absent', 'a');
    controller.reorder(MiniProgramListKind.recent, 'a', 'absent');
    controller.removeRecent('absent');
    controller.removeFromMy('absent');
    expect(notifications, 3);
  });
}
