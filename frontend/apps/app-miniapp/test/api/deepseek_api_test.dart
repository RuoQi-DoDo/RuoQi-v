import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_api.dart';

class _DeepSeekAdapter implements HttpClientAdapter {
  _DeepSeekAdapter({this.statusCode = 200});

  final int statusCode;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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
            'output_modalities': ['text'],
            'effort': {
              'supported_levels': ['low', 'high', 'max'],
              'default_level': 'high',
            },
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
      _ => jsonEncode({
        'error': {'message': 'unauthorized'},
      }),
    };
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('DeepSeek API 获取模型并注入 Bearer Key', () async {
    final adapter = _DeepSeekAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;
    final api = DeepSeekApi(dio: dio);

    final models = await api.listModels(apiKey: 'sk-test');

    expect(models, hasLength(1));
    expect(models.single.id, 'deepseek-flash');
    expect(models.single.displayName, 'DeepSeek-V4.1-Flash');
    expect(models.single.contextWindow, 1048576);
    expect(models.single.inputModalities, ['text', 'image']);
    expect(models.single.effortLevels, ['low', 'high', 'max']);
    expect(adapter.requests.single.path, '/models');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer sk-test');
  });

  test('DeepSeek API 获取账户余额', () async {
    final adapter = _DeepSeekAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;
    final api = DeepSeekApi(dio: dio);

    final balance = await api.getBalance(apiKey: 'sk-test');

    expect(balance.isAvailable, isTrue);
    expect(balance.balanceInfos.single.currency, 'CNY');
    expect(balance.balanceInfos.single.totalBalance, '110.00');
    expect(balance.balanceInfos.single.grantedBalance, '10.00');
    expect(balance.balanceInfos.single.toppedUpBalance, '100.00');
    expect(adapter.requests.single.path, '/user/balance');
  });

  test('DeepSeek API 将 401 映射为无效 Key', () async {
    final adapter = _DeepSeekAdapter(statusCode: 401);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;
    final api = DeepSeekApi(dio: dio);

    await expectLater(
      api.listModels(apiKey: 'sk-invalid'),
      throwsA(
        isA<DeepSeekApiException>().having(
          (error) => error.type,
          'type',
          DeepSeekApiErrorType.unauthorized,
        ),
      ),
    );
  });
}
