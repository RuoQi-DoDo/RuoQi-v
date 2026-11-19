import 'package:shared_preferences/shared_preferences.dart';

class DeepSeekSettings {
  const DeepSeekSettings({
    this.apiKey = '',
    this.selectedModelId = '',
    this.selectedModelName = '',
  });

  final String apiKey;
  final String selectedModelId;
  final String selectedModelName;
}

abstract interface class DeepSeekSettingsStore {
  Future<DeepSeekSettings> load();

  Future<void> saveApiKey(String apiKey);

  Future<void> saveSelectedModel({required String id, required String name});

  Future<void> clearApiKey();
}

class SharedPreferencesDeepSeekSettingsStore implements DeepSeekSettingsStore {
  const SharedPreferencesDeepSeekSettingsStore();

  static const _apiKey = 'deepseek_api_key';
  static const _modelId = 'deepseek_model_id';
  static const _modelName = 'deepseek_model_name';

  @override
  Future<DeepSeekSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return DeepSeekSettings(
      apiKey: preferences.getString(_apiKey) ?? '',
      selectedModelId: preferences.getString(_modelId) ?? '',
      selectedModelName: preferences.getString(_modelName) ?? '',
    );
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_apiKey, apiKey.trim());
  }

  @override
  Future<void> saveSelectedModel({
    required String id,
    required String name,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modelId, id);
    await preferences.setString(_modelName, name);
  }

  @override
  Future<void> clearApiKey() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_apiKey);
    await preferences.remove(_modelId);
    await preferences.remove(_modelName);
  }
}
