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

  Future<dynamic> _get(String path, {required String apiKey}) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const DeepSeekApiException(
        type: DeepSeekApiErrorType.missingApiKey,
        message: 'DeepSeek API key is required.',
      );
    }
    try {
      final response = await _dio.get<dynamic>(
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (error) {
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
