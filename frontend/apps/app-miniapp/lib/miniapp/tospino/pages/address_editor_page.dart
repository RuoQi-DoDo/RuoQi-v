import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';
import 'address_qr_scanner_page.dart';

class TospinoAddressEditorPage extends StatefulWidget {
  const TospinoAddressEditorPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoAddressEditorPage> createState() =>
      _TospinoAddressEditorPageState();
}

class _TospinoAddressEditorPageState extends State<TospinoAddressEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _backupPhone;
  late final TextEditingController _details;
  late String _phonePrefix;
  late String _backupPrefix;
  late List<TospinoRegion> _regionPath;
  late bool _isDefault;
  late String _tag;
  late String _customTag;
  bool _saving = false;
  bool _resolvingScannedRegion = false;

  TospinoAddress? get _editing => widget.controller.editingAddress;

  @override
  void initState() {
    super.initState();
    final address = _editing;
    _name = TextEditingController(text: address?.name ?? '');
    _phone = TextEditingController(text: address?.phone ?? '');
    _backupPhone = TextEditingController(text: address?.sparePhone ?? '');
    _details = TextEditingController(text: address?.streetAddress ?? '');
    _phonePrefix = address?.phonePrefix.isNotEmpty == true
        ? address!.phonePrefix
        : '+233';
    _backupPrefix = address?.sparePhonePrefix.isNotEmpty == true
        ? address!.sparePhonePrefix
        : '+233';
    _regionPath = List.of(address?.regionPath ?? const []);
    _isDefault = address?.isDefault ?? widget.controller.addresses.isEmpty;
    _customTag = address?.tagEditor ?? '';
    _tag = _customTag.isEmpty ? (address?.tag ?? '') : '';
    _name.addListener(_refresh);
    _phone.addListener(_refresh);
    _backupPhone.addListener(_refresh);
    _details.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
      if (_editing == null) unawaited(_showScanTip());
    });
  }

  @override
  void dispose() {
    _name
      ..removeListener(_refresh)
      ..dispose();
    _phone
      ..removeListener(_refresh)
      ..dispose();
    _backupPhone
      ..removeListener(_refresh)
      ..dispose();
    _details
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool get _validPhone =>
      _normalizedPhone(_phone.text, _phonePrefix).isNotEmpty;

  bool get _validRegion =>
      _regionPath.length >= 3 &&
      _regionPath.take(3).every((region) => region.code.isNotEmpty);

  bool get _canSave =>
      _name.text.trim().isNotEmpty &&
      _validPhone &&
      _validRegion &&
      _details.text.trim().isNotEmpty &&
      !_saving;

  String _normalizedPhone(String value, String prefix) {
    final compact = value.replaceAll(RegExp(r'\s+'), '');
    String number;
    if (prefix.isNotEmpty && compact.startsWith(prefix)) {
      number = compact.substring(prefix.length);
    } else if (compact.startsWith('+')) {
      final match = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(compact);
      if (match == null) return '';
      final typedPrefix = match.group(1)!;
      number = typedPrefix == prefix ? match.group(2)! : '';
    } else if (prefix.isNotEmpty &&
        compact.startsWith(prefix.replaceFirst('+', ''))) {
      number = compact.substring(prefix.length - 1);
    } else {
      number = compact;
    }
    number = number.replaceAll(RegExp(r'[^0-9]'), '');
    number = number.replaceFirst(RegExp(r'^0+'), '');
    if (prefix == '+233') {
      return number.length == 9 ? number : '';
    }
    return number.length >= 7 && number.length <= 15 ? number : '';
  }

  Future<void> _pickPhonePrefix({required bool backup}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhonePrefixPicker(
        controller: widget.controller,
        selected: backup ? _backupPrefix : _phonePrefix,
      ),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    setState(() {
      if (backup) {
        _backupPrefix = selected;
      } else {
        _phonePrefix = selected;
      }
    });
  }

  Future<void> _pickRegion() async {
    final path = await showModalBottomSheet<List<TospinoRegion>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressRegionPicker(controller: widget.controller),
    );
    if (path == null || path.isEmpty || !mounted) return;
    setState(() => _regionPath = path);
  }

  Future<void> _showScanTip() async {
    final startScan = await showDialog<bool>(
      context: context,
      builder: (context) => const _ScanAddressTipDialog(),
    );
    if (startScan == true && mounted) await _scanAddress();
  }

  Future<void> _scanAddress() async {
    final result = await Navigator.of(context).push<TospinoAddressQrData>(
      MaterialPageRoute(builder: (_) => const TospinoAddressScannerPage()),
    );
    if (result == null || !mounted) return;
    _details.text = result.detailAddress;
    if (!result.hasCoordinates) {
      showTospinoToast(context, '地址已回填，请手动选择地区');
      return;
    }
    setState(() => _resolvingScannedRegion = true);
    try {
      final regionPath = await widget.controller.resolveRegionsByCoordinates(
        longitude: result.longitude!,
        latitude: result.latitude!,
      );
      if (!mounted) return;
      if (regionPath.isNotEmpty) {
        setState(() => _regionPath = regionPath);
        showTospinoToast(context, '地址和地区已自动填写');
      } else {
        showTospinoToast(context, '地址已回填，请手动确认地区');
      }
    } catch (error) {
      if (mounted) showTospinoToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _resolvingScannedRegion = false);
    }
  }

  Future<void> _chooseCustomTag() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _CustomTagDialog(initialValue: _customTag),
    );
    if (value == null || !mounted) return;
    setState(() {
      _customTag = value;
      _tag = '';
    });
  }

  Future<void> _delete() async {
    final address = _editing;
    if (address == null || _saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizeMiniProgramLabel(context, '删除收货地址')),
        content: Text(localizeMiniProgramLabel(context, '确定要删除这个收货地址吗？')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizeMiniProgramLabel(context, '取消')),
          ),
          TextButton(
            key: const Key('tospino-address-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizeMiniProgramLabel(context, '删除')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await widget.controller.deleteAddress(address);
      if (!mounted) return;
      widget.controller.back();
      showTospinoToast(context, '地址已删除');
    } catch (error) {
      if (mounted) showTospinoToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final phone = _normalizedPhone(_phone.text, _phonePrefix);
    final backup = _backupPhone.text.trim().isEmpty
        ? ''
        : _normalizedPhone(_backupPhone.text, _backupPrefix);
    if (backup.isEmpty && _backupPhone.text.trim().isNotEmpty) {
      showTospinoToast(context, '请输入有效的备用手机号码');
      return;
    }
    final regionNames = _regionPath.map((region) => region.name).toList();
    final details = _details.text.trim();
    final address = TospinoAddress(
      id: _editing?.id ?? '',
      name: _name.text.trim(),
      phone: phone,
      phonePrefix: _phonePrefix,
      sparePhone: backup,
      sparePhonePrefix: _backupPrefix,
      detailAddress: details,
      completeAddress: [...regionNames, details].join(', '),
      isDefault: _isDefault,
      countryCode: _regionPath[0].code,
      countryName: _regionPath[0].name,
      provinceCode: _regionPath[1].code,
      province: _regionPath[1].name,
      cityCode: _regionPath[2].code,
      city: _regionPath[2].name,
      districtCode: _regionPath.length > 3 ? _regionPath[3].code : '',
      tag: _tag,
      tagEditor: _customTag,
      doorplateInfo: _editing?.doorplateInfo ?? '',
      regionPath: _regionPath,
    );
    setState(() => _saving = true);
    try {
      await widget.controller.saveAddress(address, isDefault: _isDefault);
      if (!mounted) return;
      widget.controller.back();
      showTospinoToast(context, '地址已保存');
    } catch (error) {
      if (mounted) showTospinoToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = _editing != null;
    return ColoredBox(
      key: const Key('tospino-address-editor-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                12,
                10,
                12,
                96 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.brandPale,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 17,
                        color: TospinoColors.solidBrand(context),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          localizeMiniProgramLabel(context, '所有资料都会被加密'),
                          style: TospinoText.secondary(
                            context,
                          ).copyWith(color: TospinoColors.solidBrand(context)),
                        ),
                      ),
                      if (editing)
                        TextButton(
                          key: const Key('tospino-address-delete'),
                          onPressed: _saving ? null : _delete,
                          style: TextButton.styleFrom(
                            foregroundColor: TospinoColors.resolve(
                              context,
                              TospinoColors.price,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(localizeMiniProgramLabel(context, '删除')),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _EditorCard(
                  children: [
                    _FieldLabel(label: '收货人'),
                    const SizedBox(height: 7),
                    TextField(
                      key: const Key('tospino-address-name-field'),
                      controller: _name,
                      maxLength: 30,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: localizeMiniProgramLabel(context, '请输入收货人姓名'),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _FieldLabel(label: '手机号码'),
                    const SizedBox(height: 7),
                    _PhoneField(
                      fieldKey: const Key('tospino-address-phone-field'),
                      prefixKey: const Key('tospino-address-phone-prefix'),
                      prefix: _phonePrefix,
                      controller: _phone,
                      onPrefixTap: () => _pickPhonePrefix(backup: false),
                    ),
                    const SizedBox(height: 15),
                    _FieldLabel(label: '备用手机号码', optional: true),
                    const SizedBox(height: 7),
                    _PhoneField(
                      fieldKey: const Key('tospino-address-backup-phone-field'),
                      prefixKey: const Key(
                        'tospino-address-backup-phone-prefix',
                      ),
                      prefix: _backupPrefix,
                      controller: _backupPhone,
                      onPrefixTap: () => _pickPhonePrefix(backup: true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _EditorCard(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: _FieldLabel(label: '详细地址')),
                        IconButton(
                          key: const Key('tospino-address-scan-help'),
                          tooltip: localizeMiniProgramLabel(context, '查看扫码说明'),
                          onPressed: _showScanTip,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                          ),
                        ),
                        IconButton(
                          key: const Key('tospino-address-scan'),
                          tooltip: localizeMiniProgramLabel(context, '扫描地址二维码'),
                          onPressed: _resolvingScannedRegion
                              ? null
                              : _scanAddress,
                          visualDensity: VisualDensity.compact,
                          icon: _resolvingScannedRegion
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 20,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      key: const Key('tospino-address-detail-field'),
                      controller: _details,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 255,
                      decoration: InputDecoration(
                        hintText: localizeMiniProgramLabel(
                          context,
                          '街道、门牌号、楼栋和房间号',
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _FieldLabel(label: '国家/省/城市'),
                    const SizedBox(height: 7),
                    InkWell(
                      key: const Key('tospino-address-region-field'),
                      onTap: _pickRegion,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.chevron_right_rounded),
                        ),
                        child: Text(
                          _regionPath.isEmpty
                              ? localizeMiniProgramLabel(context, '请选择国家和地区')
                              : _regionPath
                                    .map((region) => region.name)
                                    .join(' / '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _regionPath.isEmpty
                              ? TospinoText.hint(context)
                              : TospinoText.body(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _EditorCard(
                  children: [
                    _FieldLabel(label: '地址标签'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TagChoice(
                          key: const Key('tospino-address-tag-home'),
                          label: '家',
                          selected: _tag == '1' && _customTag.isEmpty,
                          onTap: () => setState(() {
                            _tag = '1';
                            _customTag = '';
                          }),
                        ),
                        _TagChoice(
                          key: const Key('tospino-address-tag-company'),
                          label: '公司',
                          selected: _tag == '2' && _customTag.isEmpty,
                          onTap: () => setState(() {
                            _tag = '2';
                            _customTag = '';
                          }),
                        ),
                        _TagChoice(
                          key: const Key('tospino-address-tag-school'),
                          label: '学校',
                          selected: _tag == '3' && _customTag.isEmpty,
                          onTap: () => setState(() {
                            _tag = '3';
                            _customTag = '';
                          }),
                        ),
                        _TagChoice(
                          key: const Key('tospino-address-tag-custom'),
                          label: _customTag.isEmpty ? '+ 自定义' : _customTag,
                          selected: _customTag.isNotEmpty,
                          onTap: _chooseCustomTag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      key: const Key('tospino-address-default-switch'),
                      contentPadding: EdgeInsets.zero,
                      value: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                      title: Text(
                        localizeMiniProgramLabel(context, '设为默认地址'),
                        style: TospinoText.body(context),
                      ),
                    ),
                    Text(
                      localizeMiniProgramLabel(context, '设置默认地址后，下单时会优先使用该地址。'),
                      style: TospinoText.hint(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.surface),
                border: Border(
                  top: BorderSide(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: TospinoGradientButton(
                  key: const Key('tospino-address-save'),
                  label: _saving ? '保存中…' : '保存地址',
                  onPressed: _canSave ? _save : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      radius: 16,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.optional = false});

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          localizeMiniProgramLabel(context, label),
          style: TospinoText.bodyStrong(context),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            localizeMiniProgramLabel(context, '选填'),
            style: TospinoText.hint(context),
          ),
        ],
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.fieldKey,
    required this.prefixKey,
    required this.prefix,
    required this.controller,
    required this.onPrefixTap,
  });

  final String prefix;
  final Key fieldKey;
  final Key prefixKey;
  final TextEditingController controller;
  final VoidCallback onPrefixTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
        LengthLimitingTextInputFormatter(20),
      ],
      decoration: InputDecoration(
        hintText: localizeMiniProgramLabel(context, '请输入手机号码'),
        prefixIcon: InkWell(
          key: prefixKey,
          onTap: onPrefixTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(prefix, style: TospinoText.body(context)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_drop_down_rounded, size: 18),
              ],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 72),
      ),
    );
  }
}

class _TagChoice extends StatelessWidget {
  const _TagChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(localizeMiniProgramLabel(context, label)),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: TospinoColors.resolve(context, TospinoColors.brandPale),
      backgroundColor: TospinoColors.resolve(context, TospinoColors.tint),
      side: BorderSide(
        color: selected
            ? TospinoColors.solidBrand(context)
            : Colors.transparent,
      ),
      labelStyle: TextStyle(
        color: selected
            ? TospinoColors.solidBrand(context)
            : TospinoColors.resolve(context, TospinoColors.secondary),
        fontSize: 13,
        fontWeight: selected ? TospinoText.emphasis : TospinoText.regular,
      ),
    );
  }
}

class _ScanAddressTipDialog extends StatelessWidget {
  const _ScanAddressTipDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('tospino-address-scan-tip'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: TospinoColors.resolve(context, TospinoColors.surface),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    key: const Key('tospino-address-scan-tip-close'),
                    tooltip: localizeMiniProgramLabel(context, '关闭'),
                    onPressed: () => Navigator.of(context).pop(false),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 72,
                      decoration: BoxDecoration(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.surfaceMuted,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.line,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: TospinoColors.resolve(
                                    context,
                                    TospinoColors.ink,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizeMiniProgramLabel(context, '快速填充'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TospinoText.hint(
                                  context,
                                ).copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizeMiniProgramLabel(context, '扫描二维码快速填充收货地址'),
                            style: TospinoText.bodyStrong(context),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizeMiniProgramLabel(
                              context,
                              '支持门牌二维码，也可以手动填写。',
                            ),
                            style: TospinoText.secondary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const Key('tospino-address-scan-tip-start'),
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: Text(localizeMiniProgramLabel(context, '开始扫描')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTagDialog extends StatefulWidget {
  const _CustomTagDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_CustomTagDialog> createState() => _CustomTagDialogState();
}

class _CustomTagDialogState extends State<_CustomTagDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(localizeMiniProgramLabel(context, '自定义地址标签')),
      content: TextField(
        key: const Key('tospino-address-custom-tag-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 12,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: localizeMiniProgramLabel(context, '例如：父母家、仓库'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizeMiniProgramLabel(context, '取消')),
        ),
        FilledButton(
          key: const Key('tospino-address-custom-tag-save'),
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isNotEmpty) Navigator.of(context).pop(value);
          },
          child: Text(localizeMiniProgramLabel(context, '确定')),
        ),
      ],
    );
  }
}

class _PhonePrefixPicker extends StatefulWidget {
  const _PhonePrefixPicker({required this.controller, required this.selected});

  final TospinoAppController controller;
  final String selected;

  @override
  State<_PhonePrefixPicker> createState() => _PhonePrefixPickerState();
}

class _PhonePrefixPickerState extends State<_PhonePrefixPicker> {
  late Future<List<TospinoPhonePrefix>> _prefixes;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefixes = widget.controller.fetchPhonePrefixes();
    _search.addListener(_refresh);
  }

  @override
  void dispose() {
    _search
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.lineStrong),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
              child: Text(
                localizeMiniProgramLabel(context, '选择手机区号'),
                style: TospinoText.pageTitle(context).copyWith(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: localizeMiniProgramLabel(context, '搜索国家或区号'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TospinoPhonePrefix>>(
                future: _prefixes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var items = snapshot.data ?? const <TospinoPhonePrefix>[];
                  if (items.isEmpty) {
                    items = const [
                      TospinoPhonePrefix(country: 'Ghana', prefix: '+233'),
                      TospinoPhonePrefix(country: 'Nigeria', prefix: '+234'),
                      TospinoPhonePrefix(country: 'China', prefix: '+86'),
                      TospinoPhonePrefix(
                        country: 'United States',
                        prefix: '+1',
                      ),
                      TospinoPhonePrefix(
                        country: 'United Kingdom',
                        prefix: '+44',
                      ),
                    ];
                  }
                  final query = _search.text.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    items = items
                        .where(
                          (item) =>
                              item.country.toLowerCase().contains(query) ||
                              item.prefix.contains(query),
                        )
                        .toList(growable: false);
                  }
                  if (items.isEmpty) {
                    return Center(
                      child: Text(localizeMiniProgramLabel(context, '没有匹配的区号')),
                    );
                  }
                  return ListView.separated(
                    key: const Key('tospino-phone-prefix-list'),
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 18),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = item.prefix == widget.selected;
                      return Material(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.surface,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        child: ListTile(
                          key: Key('tospino-phone-prefix-${item.prefix}'),
                          onTap: () => Navigator.of(context).pop(item.prefix),
                          title: Text(
                            item.country.isEmpty
                                ? localizeMiniProgramLabel(context, '国际区号')
                                : item.country,
                            style: TospinoText.body(context),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.prefix,
                                style: TospinoText.bodyStrong(context),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 7),
                                Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: TospinoColors.solidBrand(context),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRegionPicker extends StatefulWidget {
  const _AddressRegionPicker({required this.controller});

  final TospinoAppController controller;

  @override
  State<_AddressRegionPicker> createState() => _AddressRegionPickerState();
}

class _AddressRegionPickerState extends State<_AddressRegionPicker> {
  final List<TospinoRegion> _path = [];
  late Future<List<TospinoRegion>> _regions;

  @override
  void initState() {
    super.initState();
    _load('0');
  }

  void _load(String parentId) {
    _regions = widget.controller.fetchRegions(parentId: parentId);
  }

  void _back() {
    if (_path.isEmpty) return;
    setState(() {
      _path.removeLast();
      _load(_path.isEmpty ? '0' : _path.last.id);
    });
  }

  void _select(TospinoRegion region) {
    final next = [..._path, region];
    if (!region.hasChildren) {
      Navigator.of(context).pop(next);
      return;
    }
    setState(() {
      _path
        ..clear()
        ..addAll(next);
      _load(region.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.lineStrong),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _path.isEmpty
                        ? () => Navigator.of(context).pop()
                        : _back,
                    icon: Icon(
                      _path.isEmpty
                          ? Icons.close_rounded
                          : Icons.arrow_back_rounded,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _path.isEmpty
                          ? localizeMiniProgramLabel(context, '选择国家')
                          : _path.last.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.pageTitle(
                        context,
                      ).copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            if (_path.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _path.map((region) => region.name).join(' / '),
                    style: TospinoText.meta(context),
                  ),
                ),
              ),
            Expanded(
              child: FutureBuilder<List<TospinoRegion>>(
                future: _regions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(
                            () => _load(_path.isEmpty ? '0' : _path.last.id),
                          );
                        },
                        child: Text(localizeMiniProgramLabel(context, '重试')),
                      ),
                    );
                  }
                  final regions = snapshot.data ?? const [];
                  if (regions.isEmpty) {
                    return Center(
                      child: Text(localizeMiniProgramLabel(context, '暂无地区数据')),
                    );
                  }
                  return ListView.separated(
                    key: const Key('tospino-region-list'),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: regions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final region = regions[index];
                      return Material(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.surface,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        child: ListTile(
                          key: Key('tospino-region-${region.id}'),
                          onTap: () => _select(region),
                          title: Text(
                            region.name,
                            style: TospinoText.body(context),
                          ),
                          trailing: region.hasChildren
                              ? const Icon(Icons.chevron_right_rounded)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_path.length >= 3)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: SafeArea(
                  top: false,
                  child: TospinoGradientButton(
                    key: const Key('tospino-region-confirm'),
                    label: '使用此地区',
                    onPressed: () => Navigator.of(context).pop(List.of(_path)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
