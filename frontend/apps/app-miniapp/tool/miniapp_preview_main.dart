import 'package:flutter/material.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_miniapp.dart';

const _preview = String.fromEnvironment(
  'MINIAPP_PREVIEW',
  defaultValue: 'tospino',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      home: switch (_preview) {
        'ats' => const AtsMiniProgram(),
        'hr' => const HrMiniProgram(),
        _ => const TospinoMiniProgram(),
      },
    ),
  );
}
