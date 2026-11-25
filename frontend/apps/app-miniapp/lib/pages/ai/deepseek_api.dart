import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class DeepSeekApi {
  DeepSeekApi({Dio? dio, String baseUrl = 'https://api.deepseek.com'})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  Future<List<DeepSeekModel>> listModels({required String apiKey}) async {
    final data = await _get('/models', apiKey: apiKey);
    if (data is! Map<String, dynamic> || data['data'] is! List) {
      throw const DeepSeekApiException(
        type: DeepSeekApiErrorType.invalidResponse,
        message: 'DeepSeek returned an invalid model list.',
      );
    }
    return (data['data'] as List)
        .whereType<Map>()
        .map((item) => DeepSeekModel.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<DeepSeekBalance> getBalance({required String apiKey}) async {
    final data = await _get('/user/balance', apiKey: apiKey);
    if (data is! Map<String, dynamic>) {
      throw const DeepSeekApiException(
        type: DeepSeekApiErrorType.invalidResponse,
        message: 'DeepSeek returned an invalid balance response.',
      );
    }
    return DeepSeekBalance.fromJson(data);
  }

  Stream<DeepSeekChatChunk> streamChatCompletion({
    required String apiKey,
    required String model,
    required List<DeepSeekChatMessage> messages,
    bool thinking = false,
    bool webSearch = false,
    int? maxTokens,
    double? temperature,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'stream': true,
      'stream_options': {'include_usage': true},
      'thinking': {'type': thinking ? 'enabled' : 'disabled'},
      if (thinking) 'reasoning_effort': 'high',
      'max_tokens': ?maxTokens,
      'temperature': ?temperature,
      if (webSearch)
        'tools': [
          {'type': 'deepseek_web_search'},
        ],
    };
    try {
      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: _headers(apiKey),
        ),
      );
      final responseBody = response.data;
      if (responseBody == null) {
        throw const DeepSeekApiException(
          type: DeepSeekApiErrorType.invalidResponse,
          message: 'DeepSeek returned an empty chat stream.',
        );
      }
      final lines = utf8.decoder
          .bind(responseBody.stream)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (!line.startsWith('data:')) {
          continue;
        }
        final payload = line.substring(5).trim();
        if (payload.isEmpty || payload == '[DONE]') {
          continue;
        }
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) {
          continue;
        }
        final choices = decoded['choices'];
        if (choices is! List || choices.isEmpty || choices.first is! Map) {
          continue;
        }
        final choice = (choices.first as Map).cast<String, dynamic>();
        final delta = choice['delta'] is Map
            ? (choice['delta'] as Map).cast<String, dynamic>()
            : const <String, dynamic>{};
        yield DeepSeekChatChunk(
          content: delta['content'] as String? ?? '',
          reasoningContent: delta['reasoning_content'] as String? ?? '',
          finishReason: choice['finish_reason'] as String?,
          usage: decoded['usage'] is Map
              ? DeepSeekUsage.fromJson(
                  (decoded['usage'] as Map).cast<String, dynamic>(),
                )
              : null,
        );
      }
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Future<DeepSeekFile> uploadFile({
    required String apiKey,
    required String filename,
    required Uint8List bytes,
    String purpose = 'user_data',
    int? expiresAfterSeconds,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('purpose', purpose));
    if (expiresAfterSeconds != null) {
      form.fields.add(MapEntry('expires_after[anchor]', 'created_at'));
      form.fields.add(
        MapEntry('expires_after[seconds]', '$expiresAfterSeconds'),
      );
    }
    form.files.add(
      MapEntry('file', MultipartFile.fromBytes(bytes, filename: filename)),
    );
    final data = await _multipart(
      '/files',
      apiKey: apiKey,
      form: form,
      onSendProgress: onSendProgress,
    );
    return DeepSeekFile.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekFileList> listFiles({
    required String apiKey,
    String? after,
    int limit = 1000,
    String order = 'asc',
    String? purpose,
  }) async {
    final data = await _get(
      '/files',
      apiKey: apiKey,
      queryParameters: {
        'after': ?after,
        'limit': limit,
        'order': order,
        'purpose': ?purpose,
      },
    );
    return DeepSeekFileList.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekFile> retrieveFile({
    required String apiKey,
    required String fileId,
  }) async {
    final data = await _get('/files/$fileId', apiKey: apiKey);
    return DeepSeekFile.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekDeletedFile> deleteFile({
    required String apiKey,
    required String fileId,
  }) async {
    final data = await _delete('/files/$fileId', apiKey: apiKey);
    return DeepSeekDeletedFile.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekSearchResults> search(
    String query, {
    required String apiKey,
    int count = 10,
    String? originalQuestion,
    String localization = '',
    bool needContent = false,
  }) async {
    final data = await _postJson(
      '/v1/tools/search',
      apiKey: apiKey,
      body: {
        'query': query,
        'count': count,
        'ori_question': ?originalQuestion,
        'localization': localization,
        'need_content': needContent,
      },
    );
    return DeepSeekSearchResults.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekFetchedPage> fetchPage({
    required String apiKey,
    required String url,
  }) async {
    final data = await _postJson(
      '/v1/tools/fetch',
      apiKey: apiKey,
      body: {'url': url},
    );
    return DeepSeekFetchedPage.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekOcrResult> ocr({
    required String apiKey,
    required String filename,
    required Uint8List bytes,
    String purpose = 'text_recognition',
  }) async {
    final form = FormData();
    form.fields.add(MapEntry('purpose', purpose));
    form.files.add(
      MapEntry('file', MultipartFile.fromBytes(bytes, filename: filename)),
    );
    final data = await _multipart('/v1/tools/ocr', apiKey: apiKey, form: form);
    return DeepSeekOcrResult.fromJson(_asJsonMap(data));
  }

  Future<DeepSeekAudioData> textToSpeech({
    required String apiKey,
    required String text,
    String voiceId = 'stella',
    String format = 'wav',
    bool filterMarkdown = true,
  }) async {
    try {
      final response = await _dio.post<List<int>>(
        '/v1/tools/tts',
        data: {
          'text': text,
          'voice_id': voiceId,
          'format': format,
          'filter_markdown': filterMarkdown,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: _headers(apiKey),
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const DeepSeekApiException(
          type: DeepSeekApiErrorType.invalidResponse,
          message: 'DeepSeek returned empty audio data.',
        );
      }
      final audioBytes = format == 'wav'
          ? _normalizeWavLengths(Uint8List.fromList(bytes))
          : Uint8List.fromList(bytes);
      return DeepSeekAudioData(
        bytes: audioBytes,
        contentType: response.headers.value(Headers.contentTypeHeader),
      );
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Future<DeepSeekTranscription> speechToText({
    required String apiKey,
    required String filename,
    required Uint8List bytes,
  }) async {
    final form = FormData();
    form.files.add(
      MapEntry('file', MultipartFile.fromBytes(bytes, filename: filename)),
    );
    final data = await _multipart('/v1/tools/asr', apiKey: apiKey, form: form);
    return DeepSeekTranscription.fromJson(_asJsonMap(data));
  }

  Future<dynamic> _postJson(
    String path, {
    required String apiKey,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(headers: _headers(apiKey)),
      );
      return response.data;
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Future<dynamic> _get(
    String path, {
    required String apiKey,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _headers(apiKey)),
      );
      return response.data;
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Future<dynamic> _delete(String path, {required String apiKey}) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        options: Options(headers: _headers(apiKey)),
      );
      return response.data;
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Future<dynamic> _multipart(
    String path, {
    required String apiKey,
    required FormData form,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: form,
        options: Options(headers: _headers(apiKey)),
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (error) {
      _throwMapped(error);
    }
  }

  Map<String, String> _headers(String apiKey) {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const DeepSeekApiException(
        type: DeepSeekApiErrorType.missingApiKey,
        message: 'DeepSeek API key is required.',
      );
    }
    return {'Authorization': 'Bearer $key', 'Accept': 'application/json'};
  }

  Never _throwMapped(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _errorMessage(error.response?.data);
    if (statusCode == 401 || statusCode == 403) {
      throw DeepSeekApiException(
        type: DeepSeekApiErrorType.unauthorized,
        statusCode: statusCode,
        message: message ?? 'DeepSeek API key is invalid or expired.',
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      throw DeepSeekApiException(
        type: DeepSeekApiErrorType.network,
        statusCode: statusCode,
        message: message ?? 'Unable to connect to DeepSeek.',
      );
    }
    throw DeepSeekApiException(
      type: statusCode != null && statusCode >= 500
          ? DeepSeekApiErrorType.server
          : DeepSeekApiErrorType.request,
      statusCode: statusCode,
      message: message ?? 'DeepSeek request failed.',
    );
  }

  String? _errorMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      if (data['message'] is String) {
        return data['message'] as String;
      }
    }
    return null;
  }
}

enum DeepSeekApiErrorType {
  missingApiKey,
  unauthorized,
  network,
  server,
  invalidResponse,
  request,
}

class DeepSeekApiException implements Exception {
  const DeepSeekApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final DeepSeekApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'DeepSeekApiException($type, $message)';
}

class DeepSeekModel {
  const DeepSeekModel({
    required this.id,
    required this.ownedBy,
    this.name,
    this.contextWindow,
    this.maxOutputTokens,
    this.inputModalities = const [],
    this.outputModalities = const [],
    this.effortLevels = const [],
    this.defaultEffort,
  });

  final String id;
  final String ownedBy;
  final String? name;
  final int? contextWindow;
  final int? maxOutputTokens;
  final List<String> inputModalities;
  final List<String> outputModalities;
  final List<String> effortLevels;
  final String? defaultEffort;

  String get displayName => name?.trim().isNotEmpty == true ? name!.trim() : id;

  factory DeepSeekModel.fromJson(Map<String, dynamic> json) {
    final effort = json['effort'];
    return DeepSeekModel(
      id: json['id'] as String? ?? '',
      ownedBy: json['owned_by'] as String? ?? '',
      name: json['name'] as String?,
      contextWindow: _asInt(json['context_window']),
      maxOutputTokens: _asInt(json['max_output_tokens']),
      inputModalities: _stringList(json['input_modalities']),
      outputModalities: _stringList(json['output_modalities']),
      effortLevels: effort is Map
          ? _stringList(effort['supported_levels'])
          : const [],
      defaultEffort: effort is Map ? effort['default_level'] as String? : null,
    );
  }
}

class DeepSeekBalance {
  const DeepSeekBalance({
    required this.isAvailable,
    required this.balanceInfos,
  });

  final bool isAvailable;
  final List<DeepSeekBalanceInfo> balanceInfos;

  factory DeepSeekBalance.fromJson(Map<String, dynamic> json) {
    final infos = json['balance_infos'];
    return DeepSeekBalance(
      isAvailable: json['is_available'] as bool? ?? false,
      balanceInfos: infos is List
          ? infos
                .whereType<Map>()
                .map(
                  (item) => DeepSeekBalanceInfo.fromJson(
                    item.cast<String, dynamic>(),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class DeepSeekBalanceInfo {
  const DeepSeekBalanceInfo({
    required this.currency,
    required this.totalBalance,
    required this.grantedBalance,
    required this.toppedUpBalance,
  });

  final String currency;
  final String totalBalance;
  final String grantedBalance;
  final String toppedUpBalance;

  factory DeepSeekBalanceInfo.fromJson(Map<String, dynamic> json) {
    return DeepSeekBalanceInfo(
      currency: json['currency'] as String? ?? '',
      totalBalance: json['total_balance'] as String? ?? '0',
      grantedBalance: json['granted_balance'] as String? ?? '0',
      toppedUpBalance: json['topped_up_balance'] as String? ?? '0',
    );
  }
}

class DeepSeekChatMessage {
  const DeepSeekChatMessage({required this.role, required this.content});

  final String role;
  final Object content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class DeepSeekChatChunk {
  const DeepSeekChatChunk({
    required this.content,
    required this.reasoningContent,
    this.finishReason,
    this.usage,
  });

  final String content;
  final String reasoningContent;
  final String? finishReason;
  final DeepSeekUsage? usage;
}

class DeepSeekUsage {
  const DeepSeekUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  factory DeepSeekUsage.fromJson(Map<String, dynamic> json) {
    return DeepSeekUsage(
      promptTokens: _asInt(json['prompt_tokens']) ?? 0,
      completionTokens: _asInt(json['completion_tokens']) ?? 0,
      totalTokens: _asInt(json['total_tokens']) ?? 0,
    );
  }
}

class DeepSeekFile {
  const DeepSeekFile({
    required this.id,
    required this.bytes,
    required this.createdAt,
    required this.filename,
    required this.purpose,
    this.expiresAt,
  });

  final String id;
  final int bytes;
  final int createdAt;
  final String filename;
  final String purpose;
  final int? expiresAt;

  factory DeepSeekFile.fromJson(Map<String, dynamic> json) {
    return DeepSeekFile(
      id: json['id'] as String? ?? '',
      bytes: _asInt(json['bytes']) ?? 0,
      createdAt: _asInt(json['created_at']) ?? 0,
      filename: json['filename'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      expiresAt: _asInt(json['expires_at']),
    );
  }
}

class DeepSeekFileList {
  const DeepSeekFileList({
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  final List<DeepSeekFile> data;
  final bool hasMore;
  final String? firstId;
  final String? lastId;

  factory DeepSeekFileList.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DeepSeekFileList(
      data: data is List
          ? data
                .whereType<Map>()
                .map(
                  (item) => DeepSeekFile.fromJson(item.cast<String, dynamic>()),
                )
                .toList(growable: false)
          : const [],
      hasMore: json['has_more'] as bool? ?? false,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }
}

class DeepSeekDeletedFile {
  const DeepSeekDeletedFile({required this.id, required this.deleted});

  final String id;
  final bool deleted;

  factory DeepSeekDeletedFile.fromJson(Map<String, dynamic> json) {
    return DeepSeekDeletedFile(
      id: json['id'] as String? ?? '',
      deleted: json['deleted'] as bool? ?? false,
    );
  }
}

class DeepSeekSearchResults {
  const DeepSeekSearchResults({required this.results});

  final List<DeepSeekSearchResult> results;

  factory DeepSeekSearchResults.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    return DeepSeekSearchResults(
      results: results is List
          ? results
                .whereType<Map>()
                .map(
                  (item) => DeepSeekSearchResult.fromJson(
                    item.cast<String, dynamic>(),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class DeepSeekSearchResult {
  const DeepSeekSearchResult({
    required this.title,
    required this.url,
    required this.snippet,
    required this.summary,
    required this.content,
    required this.authority,
    required this.rerankScore,
    this.siteName,
    this.siteIcon,
    this.date,
  });

  final String title;
  final String url;
  final String snippet;
  final String summary;
  final String content;
  final int authority;
  final double rerankScore;
  final String? siteName;
  final String? siteIcon;
  final String? date;

  factory DeepSeekSearchResult.fromJson(Map<String, dynamic> json) {
    return DeepSeekSearchResult(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authority: _asInt(json['authority']) ?? -1,
      rerankScore: (json['rerank_score'] as num?)?.toDouble() ?? 0,
      siteName: json['site_name'] as String?,
      siteIcon: json['site_icon'] as String?,
      date: json['date'] as String?,
    );
  }
}

class DeepSeekFetchedPage {
  const DeepSeekFetchedPage({required this.title, required this.content});

  final String title;
  final String content;

  factory DeepSeekFetchedPage.fromJson(Map<String, dynamic> json) {
    return DeepSeekFetchedPage(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}

class DeepSeekOcrResult {
  const DeepSeekOcrResult({
    required this.id,
    required this.pageCount,
    required this.pages,
    required this.usage,
  });

  final String id;
  final int pageCount;
  final List<DeepSeekOcrPage> pages;
  final DeepSeekUsage usage;

  factory DeepSeekOcrResult.fromJson(Map<String, dynamic> json) {
    final pages = json['pages'];
    final usage = json['usage'];
    return DeepSeekOcrResult(
      id: json['id'] as String? ?? '',
      pageCount: _asInt(json['page_count']) ?? 0,
      pages: pages is List
          ? pages
                .whereType<Map>()
                .map(
                  (item) =>
                      DeepSeekOcrPage.fromJson(item.cast<String, dynamic>()),
                )
                .toList(growable: false)
          : const [],
      usage: usage is Map
          ? DeepSeekUsage.fromJson({
              'prompt_tokens': usage['input_tokens'],
              'completion_tokens': usage['output_tokens'],
              'total_tokens': usage['total_tokens'],
            })
          : const DeepSeekUsage(
              promptTokens: 0,
              completionTokens: 0,
              totalTokens: 0,
            ),
    );
  }
}

class DeepSeekOcrPage {
  const DeepSeekOcrPage({
    required this.index,
    required this.text,
    required this.finishReason,
  });

  final int index;
  final String text;
  final String finishReason;

  factory DeepSeekOcrPage.fromJson(Map<String, dynamic> json) {
    return DeepSeekOcrPage(
      index: _asInt(json['index']) ?? 0,
      text: json['text'] as String? ?? '',
      finishReason: json['finish_reason'] as String? ?? '',
    );
  }
}

class DeepSeekAudioData {
  const DeepSeekAudioData({required this.bytes, this.contentType});

  final Uint8List bytes;
  final String? contentType;
}

class DeepSeekTranscription {
  const DeepSeekTranscription({
    required this.requestId,
    required this.text,
    required this.durationMs,
  });

  final String requestId;
  final String text;
  final int durationMs;

  factory DeepSeekTranscription.fromJson(Map<String, dynamic> json) {
    return DeepSeekTranscription(
      requestId: json['request_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      durationMs: _asInt(json['duration_ms']) ?? 0,
    );
  }
}

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  throw const DeepSeekApiException(
    type: DeepSeekApiErrorType.invalidResponse,
    message: 'DeepSeek returned an invalid response.',
  );
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

List<String> _stringList(dynamic value) {
  return value is List ? value.whereType<String>().toList(growable: false) : [];
}

Uint8List _normalizeWavLengths(Uint8List bytes) {
  if (bytes.length < 44 ||
      String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
      String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
    return bytes;
  }
  var dataHeaderOffset = -1;
  for (var index = 12; index + 8 <= bytes.length; index++) {
    if (bytes[index] == 0x64 &&
        bytes[index + 1] == 0x61 &&
        bytes[index + 2] == 0x74 &&
        bytes[index + 3] == 0x61) {
      dataHeaderOffset = index;
      break;
    }
  }
  if (dataHeaderOffset < 0) {
    return bytes;
  }
  final normalized = Uint8List.fromList(bytes);
  final view = ByteData.sublistView(normalized);
  view.setUint32(4, normalized.length - 8, Endian.little);
  view.setUint32(
    dataHeaderOffset + 4,
    normalized.length - dataHeaderOffset - 8,
    Endian.little,
  );
  return normalized;
}
