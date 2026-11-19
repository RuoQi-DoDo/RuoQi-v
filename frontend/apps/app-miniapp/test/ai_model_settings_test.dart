import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ruoqi_app_miniapp/localization.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_api.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_settings_store.dart';
import 'package:ruoqi_app_miniapp/pages/settings/settings_page.dart';

class _MemoryDeepSeekSettingsStore implements DeepSeekSettingsStore {
  DeepSeekSettings settings = const DeepSeekSettings(apiKey: 'sk-stored');

  @override
  Future<void> clearApiKey() async {
    settings = const DeepSeekSettings();
  }

  @override
  Future<DeepSeekSettings> load() async => settings;

  @override
  Future<void> saveApiKey(String apiKey) async {
    settings = DeepSeekSettings(
      apiKey: apiKey,
      selectedModelId: settings.selectedModelId,
      selectedModelName: settings.selectedModelName,
    );
  }

  @override
  Future<void> saveSelectedModel({
    required String id,
    required String name,
  }) async {
    settings = DeepSeekSettings(
      apiKey: settings.apiKey,
      selectedModelId: id,
      selectedModelName: name,
    );
  }
}

class _DeepSeekFakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = switch (options.path) {
      '/models' => jsonEncode({
        'object': 'list',
        'data': [
          {
            'id': 'deepseek-flash',
            'object': 'model',
            'owned_by': 'deepseek',
            'name': 'DeepSeek-V4.1-Flash',
            'context_window': 1048576,
            'max_output_tokens': 393216,
            'input_modalities': ['text', 'image'],
          },
          {
            'id': 'deepseek-v4-pro',
            'object': 'model',
            'owned_by': 'deepseek',
            'name': 'DeepSeek-V4-Pro',
            'context_window': 1048576,
            'max_output_tokens': 393216,
            'input_modalities': ['text'],
          },
        ],
      }),
      '/user/balance' => jsonEncode({
        'is_available': true,
        'balance_infos': [
          {
            'currency': 'CNY',
            'total_balance': '110.00',
            'granted_balance': '10.00',
            'topped_up_balance': '100.00',
          },
        ],
      }),
      _ => '{}',
    };
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('DeepSeek 模型页加载余额、模型并保存选择', (tester) async {
    final store = _MemoryDeepSeekSettingsStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _DeepSeekFakeAdapter();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: AiModelSettingsPage(
          settingsStore: store,
          api: DeepSeekApi(dio: dio),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('账户余额'), findsOneWidget);
    expect(find.text('¥110.00'), findsOneWidget);
    expect(find.text('DeepSeek-V4.1-Flash'), findsWidgets);
    expect(find.text('DeepSeek-V4-Pro'), findsOneWidget);
    expect(store.settings.selectedModelId, 'deepseek-flash');

    await tester.tap(find.byKey(const Key('ai-model-deepseek-v4-pro')));
    await tester.pumpAndSettle();
    expect(store.settings.selectedModelId, 'deepseek-v4-pro');
    expect(store.settings.selectedModelName, 'DeepSeek-V4-Pro');
  });
}
