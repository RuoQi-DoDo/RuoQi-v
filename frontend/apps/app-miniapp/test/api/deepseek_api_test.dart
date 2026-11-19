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

class _ChatStreamAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      'data: {"choices":[{"delta":{"reasoning_content":"思考中"},"finish_reason":null}]}\n\n'
      'data: {"choices":[{"delta":{"content":"你好"},"finish_reason":null}]}\n\n'
      'data: {"choices":[{"delta":{"content":"，世界"},"finish_reason":"stop"}],'
      '"usage":{"prompt_tokens":5,"completion_tokens":3,"total_tokens":8}}\n\n'
      'data: [DONE]\n\n',
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _ToolsAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch (options.path) {
      '/files' when options.method == 'POST' => jsonEncode({
        'id': 'file-api-test',
        'object': 'file',
        'bytes': 4,
        'created_at': 1700000000,
        'filename': 'note.txt',
        'purpose': 'user_data',
      }),
      '/files' => jsonEncode({
        'object': 'list',
        'data': [
          {
            'id': 'file-api-test',
            'object': 'file',
            'bytes': 4,
            'created_at': 1700000000,
            'filename': 'note.txt',
            'purpose': 'user_data',
          },
        ],
        'first_id': 'file-api-test',
        'last_id': 'file-api-test',
        'has_more': false,
      }),
      '/files/file-api-test' when options.method == 'DELETE' => jsonEncode({
        'id': 'file-api-test',
        'object': 'file',
        'deleted': true,
      }),
      '/files/file-api-test' => jsonEncode({
        'id': 'file-api-test',
        'object': 'file',
        'bytes': 4,
        'created_at': 1700000000,
        'filename': 'note.txt',
        'purpose': 'user_data',
      }),
      '/v1/tools/search' => jsonEncode({
        'results': [
          {
            'rerank_score': 2.4,
            'title': 'DeepSeek',
            'url': 'https://example.com/deepseek',
            'snippet': 'snippet',
            'summary': 'summary',
            'content': '',
            'site_name': 'Example',
            'site_icon': null,
            'date': null,
            'authority': 3,
          },
        ],
      }),
      '/v1/tools/fetch' => jsonEncode({
        'title': 'Fetched',
        'content': '# Fetched content',
      }),
      '/v1/tools/ocr' => jsonEncode({
        'id': 'ocr-test',
        'object': 'ocr.result',
        'created': 1700000000,
        'purpose': 'text_recognition',
        'page_count': 1,
        'pages': [
          {'index': 0, 'text': '识别文字', 'finish_reason': 'stop'},
        ],
        'usage': {'input_tokens': 10, 'output_tokens': 4, 'total_tokens': 14},
      }),
      '/v1/tools/tts' => 'WAV',
      '/v1/tools/asr' => jsonEncode({
        'request_id': 'asr-test',
        'text': '今天天气怎么样？',
        'duration_ms': 3200,
      }),
      _ => '{}',
    };
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [
          options.path == '/v1/tools/tts'
              ? 'audio/wav'
              : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _WavAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List(52);
    bytes.setAll(0, 'RIFF'.codeUnits);
    bytes.setAll(8, 'WAVE'.codeUnits);
    bytes.setAll(12, 'fmt '.codeUnits);
    ByteData.sublistView(bytes)
      ..setUint32(4, 0xFFFFFFFF, Endian.little)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, 24000, Endian.little)
      ..setUint32(28, 48000, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint32(40, 0xFFFFFFFF, Endian.little);
    bytes.setAll(36, 'data'.codeUnits);
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['audio/wav'],
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

  test('DeepSeek Chat Completions 解析 SSE 流式内容', () async {
    final adapter = _ChatStreamAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;
    final api = DeepSeekApi(dio: dio);

    final chunks = await api
        .streamChatCompletion(
          apiKey: 'sk-test',
          model: 'deepseek-flash',
          messages: const [DeepSeekChatMessage(role: 'user', content: '你好')],
          thinking: true,
          webSearch: true,
        )
        .toList();

    expect(chunks.map((chunk) => chunk.content).join(), '你好，世界');
    expect(chunks.first.reasoningContent, '思考中');
    expect(chunks.last.usage?.totalTokens, 8);
    expect(adapter.lastRequest?.path, '/chat/completions');
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer sk-test');
    expect(adapter.lastRequest?.data['stream'], isTrue);
    expect(adapter.lastRequest?.data['thinking']['type'], 'enabled');
    expect(adapter.lastRequest?.data['tools'], [
      {'type': 'deepseek_web_search'},
    ]);
  });

  test('DeepSeek Files、搜索、抓取、OCR、TTS、ASR 接口均可用', () async {
    final adapter = _ToolsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;
    final api = DeepSeekApi(dio: dio);
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    final uploaded = await api.uploadFile(
      apiKey: 'sk-test',
      filename: 'note.txt',
      bytes: bytes,
    );
    final files = await api.listFiles(apiKey: 'sk-test', limit: 2);
    final retrieved = await api.retrieveFile(
      apiKey: 'sk-test',
      fileId: uploaded.id,
    );
    final deleted = await api.deleteFile(
      apiKey: 'sk-test',
      fileId: uploaded.id,
    );
    final search = await api.search('DeepSeek', apiKey: 'sk-test', count: 1);
    final page = await api.fetchPage(
      apiKey: 'sk-test',
      url: 'https://example.com',
    );
    final ocr = await api.ocr(
      apiKey: 'sk-test',
      filename: 'scan.png',
      bytes: bytes,
    );
    final audio = await api.textToSpeech(apiKey: 'sk-test', text: '你好');
    final transcription = await api.speechToText(
      apiKey: 'sk-test',
      filename: 'voice.wav',
      bytes: bytes,
    );

    expect(files.data.single.filename, 'note.txt');
    expect(retrieved.id, 'file-api-test');
    expect(deleted.deleted, isTrue);
    expect(search.results.single.title, 'DeepSeek');
    expect(page.content, '# Fetched content');
    expect(ocr.pages.single.text, '识别文字');
    expect(audio.bytes, isNotEmpty);
    expect(transcription.text, '今天天气怎么样？');
    expect(
      adapter.requests.map((request) => request.path),
      containsAll([
        '/files',
        '/files/file-api-test',
        '/v1/tools/search',
        '/v1/tools/fetch',
        '/v1/tools/ocr',
        '/v1/tools/tts',
        '/v1/tools/asr',
      ]),
    );
  });

  test('TTS 流式 WAV 的未知长度头会按实际字节修正', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _WavAdapter();
    final api = DeepSeekApi(dio: dio);

    final audio = await api.textToSpeech(apiKey: 'sk-test', text: '你好');
    final view = ByteData.sublistView(audio.bytes);

    expect(audio.bytes.length, 52);
    expect(view.getUint32(4, Endian.little), 44);
    expect(view.getUint32(40, Endian.little), 8);
  });
}
