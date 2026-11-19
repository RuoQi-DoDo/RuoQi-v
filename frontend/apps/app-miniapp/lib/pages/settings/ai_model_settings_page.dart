part of 'settings_page.dart';

class AiModelSettingsPage extends StatefulWidget {
  const AiModelSettingsPage({super.key, required this.settingsStore, this.api});

  final DeepSeekSettingsStore settingsStore;
  final DeepSeekApi? api;

  static Route<void> route({
    required DeepSeekSettingsStore settingsStore,
    DeepSeekApi? api,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) =>
          AiModelSettingsPage(settingsStore: settingsStore, api: api),
    );
  }

  @override
  State<AiModelSettingsPage> createState() => _AiModelSettingsPageState();
}

class _AiModelSettingsPageState extends State<AiModelSettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  late final DeepSeekApi _api = widget.api ?? DeepSeekApi();

  List<DeepSeekModel> _models = const [];
  DeepSeekBalance? _balance;
  String _selectedModelId = '';
  String _selectedModelName = '';
  String? _error;
  bool _loading = false;
  bool _obscureKey = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await widget.settingsStore.load();
      if (!mounted) {
        return;
      }
      _apiKeyController.text = settings.apiKey;
      _selectedModelId = settings.selectedModelId;
      _selectedModelName = settings.selectedModelName;
      setState(() => _loaded = true);
      if (settings.apiKey.isNotEmpty) {
        await _connect(apiKey: settings.apiKey, persist: false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loaded = true);
      }
    }
  }

  Future<void> _connect({String? apiKey, bool persist = true}) async {
    final key = (apiKey ?? _apiKeyController.text).trim();
    if (key.isEmpty) {
      setState(
        () =>
            _error = AppLocalizations.of(context)
                .text('请输入 DeepSeek API Key', 'Enter a DeepSeek API key'),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (persist) {
        await widget.settingsStore.saveApiKey(key);
      }
      final modelsFuture = _api.listModels(apiKey: key);
      final balanceFuture = _api.getBalance(apiKey: key);
      final models = await modelsFuture;
      final balance = await balanceFuture;
      if (!mounted) {
        return;
      }
      if (models.isEmpty) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context)
              .text('该账号暂未返回可用模型', 'No models are available');
        });
        return;
      }
      DeepSeekModel selected = models.first;
      for (final model in models) {
        if (model.id == _selectedModelId) {
          selected = model;
          break;
        }
      }
      await widget.settingsStore.saveSelectedModel(
        id: selected.id,
        name: selected.displayName,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _apiKeyController.text = key;
        _models = models;
        _balance = balance;
        _selectedModelId = selected.id;
        _selectedModelName = selected.displayName;
        _loading = false;
      });
    } on DeepSeekApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = _errorMessage(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)
            .text('连接 DeepSeek 失败，请稍后重试', 'Unable to connect to DeepSeek');
      });
    }
  }

  Future<void> _clearApiKey() async {
    await widget.settingsStore.clearApiKey();
    if (!mounted) {
      return;
    }
    _apiKeyController.clear();
    setState(() {
      _models = const [];
      _balance = null;
      _error = null;
      _selectedModelId = '';
      _selectedModelName = '';
    });
  }

  Future<void> _selectModel(DeepSeekModel model) async {
    await widget.settingsStore.saveSelectedModel(
      id: model.id,
      name: model.displayName,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedModelId = model.id;
      _selectedModelName = model.displayName;
    });
  }

  String _errorMessage(DeepSeekApiException error) {
    final l10n = AppLocalizations.of(context);
    return switch (error.type) {
      DeepSeekApiErrorType.missingApiKey => l10n.text(
        '请输入 DeepSeek API Key',
        'Enter a DeepSeek API key',
      ),
      DeepSeekApiErrorType.unauthorized => l10n.text(
        'API Key 无效或已过期',
        'The API key is invalid or expired',
      ),
      DeepSeekApiErrorType.network => l10n.text(
        '无法连接 DeepSeek，请检查网络',
        'Unable to connect to DeepSeek. Check your network.',
      ),
      DeepSeekApiErrorType.server => l10n.text(
        'DeepSeek 服务暂不可用',
        'DeepSeek is temporarily unavailable',
      ),
      DeepSeekApiErrorType.invalidResponse => l10n.text(
        'DeepSeek 返回数据格式异常',
        'DeepSeek returned an invalid response',
      ),
      DeepSeekApiErrorType.request => l10n.text(
        '请求失败：${error.message}',
        'Request failed: ${error.message}',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final hostTheme = sharedPageTheme(context);
    return Theme(
      data: hostTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final l10n = AppLocalizations.of(context);
          final modelOptions = _models.indexed
              .map((entry) {
                final (index, model) = entry;
                final hasImage = model.inputModalities.contains('image');
                final limits = <String>[
                  if (model.contextWindow != null)
                    l10n.text(
                      '上下文 ${_formatTokenCount(model.contextWindow!)} tokens',
                      'Context ${_formatTokenCount(model.contextWindow!)} tokens',
                    ),
                  if (model.maxOutputTokens != null)
                    l10n.text(
                      '最大输出 ${_formatTokenCount(model.maxOutputTokens!)} tokens',
                      'Max output ${_formatTokenCount(model.maxOutputTokens!)} tokens',
                    ),
                ];
                return _AiModelOption(
                  id: model.id,
                  name: model.displayName,
                  type: hasImage
                      ? l10n.text('多模态', 'Multimodal')
                      : l10n.text('文本模型', 'Text model'),
                  description: limits.isEmpty
                      ? l10n.text('DeepSeek API 模型', 'DeepSeek API model')
                      : limits.join(' · '),
                  icon: hasImage
                      ? Icons.image_search_rounded
                      : Icons.auto_awesome_rounded,
                  color: const [
                    Color(0xFF4D6BFE),
                    Color(0xFF6D58E8),
                    Color(0xFF2E9A73),
                  ][index % 3],
                );
              })
              .toList(growable: false);
          return Scaffold(
            key: const Key('ai-model-settings-page'),
            backgroundColor: scheme.surface,
            appBar: AppBar(
              toolbarHeight: 50,
              centerTitle: true,
              backgroundColor: HostChromeStyle.appBarBackground(context),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                key: const Key('ai-model-back'),
                tooltip: pageLabel(context, '返回'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
              ),
              title: Text(
                pageLabel(context, '模型'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: const Border(),
            ),
            body: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 36),
              children: [
                const _SettingsSectionHeader('DeepSeek API'),
                _SettingsGroup(
                  rows: [
                    _DeepSeekApiKeyEditor(
                      controller: _apiKeyController,
                      obscure: _obscureKey,
                      loading: _loading,
                      onToggleVisibility: () =>
                          setState(() => _obscureKey = !_obscureKey),
                      onConnect: () => unawaited(_connect()),
                      onClear: () => unawaited(_clearApiKey()),
                    ),
                  ],
                ),
                if (_error != null) _DeepSeekErrorNotice(message: _error!),
                if (_balance != null) ...[
                  const _SettingsSectionHeader('账户余额'),
                  _SettingsGroup(
                    rows: [_DeepSeekBalanceSummary(balance: _balance!)],
                  ),
                ],
                if (_selectedModelName.isNotEmpty) ...[
                  const _SettingsSectionHeader('当前模型'),
                  _SettingsGroup(
                    rows: [_AiCurrentModelSummary(name: _selectedModelName)],
                  ),
                ],
                if (modelOptions.isNotEmpty) ...[
                  const _SettingsSectionHeader('可用模型'),
                  _SettingsGroup(
                    rows: [
                      for (final model in modelOptions)
                        _AiModelOptionRow(
                          key: Key('ai-model-${model.id}'),
                          model: model,
                          selected: model.id == _selectedModelId,
                          onTap: () {
                            final source = _models.firstWhere(
                              (item) => item.id == model.id,
                            );
                            unawaited(_selectModel(source));
                          },
                        ),
                    ],
                  ),
                ],
                if (_loaded && _models.isEmpty && !_loading && _error == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Text(
                      pageLabel(context, '输入 API Key 后可获取可用模型与账户余额。'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Text(
                    pageLabel(context, 'API Key 仅保存在本机。切换模型后，新模型将在下一次对话中生效。'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
