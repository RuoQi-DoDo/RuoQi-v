import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_style.dart';

class TospinoAddressQrData {
  const TospinoAddressQrData({
    required this.detailAddress,
    this.longitude,
    this.latitude,
  });

  final String detailAddress;
  final double? longitude;
  final double? latitude;

  bool get hasCoordinates => longitude != null && latitude != null;
}

TospinoAddressQrData? parseTospinoAddressQrCode(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;
  final normalized = value.toLowerCase();
  final addressIndex = normalized.indexOf('address:');
  final mapIndex = normalized.indexOf(',map:');
  if (addressIndex < 0 || mapIndex <= addressIndex) return null;
  final detailAddress = value
      .substring(addressIndex + 'address:'.length, mapIndex)
      .trim();
  if (detailAddress.isEmpty) return null;

  final mapValue = value.substring(mapIndex + ',map:'.length).trim();
  final uri = Uri.tryParse(mapValue);
  var query = uri?.queryParameters['query'] ?? '';
  if (query.isEmpty) {
    final match = RegExp(
      r'[?&]query=([^&]+)',
      caseSensitive: false,
    ).firstMatch(mapValue);
    query = match?.group(1) ?? '';
  }
  if (query.isNotEmpty) {
    try {
      query = Uri.decodeComponent(query);
    } catch (_) {}
  }
  final coordinates = query.split(',');
  final latitude = coordinates.isNotEmpty
      ? double.tryParse(coordinates[0].trim())
      : null;
  final longitude = coordinates.length > 1
      ? double.tryParse(coordinates[1].trim())
      : null;
  return TospinoAddressQrData(
    detailAddress: detailAddress,
    latitude: latitude,
    longitude: longitude,
  );
}

class TospinoAddressScannerPage extends StatefulWidget {
  const TospinoAddressScannerPage({super.key});

  @override
  State<TospinoAddressScannerPage> createState() =>
      _TospinoAddressScannerPageState();
}

class _TospinoAddressScannerPageState extends State<TospinoAddressScannerPage> {
  final MobileScannerController _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handlingResult = false;
  String? _error;
  Timer? _errorTimer;

  @override
  void dispose() {
    _errorTimer?.cancel();
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingResult) return;
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
    if (rawValue.isEmpty) return;
    final result = parseTospinoAddressQrCode(rawValue);
    if (result == null) {
      _showInvalidCode();
      return;
    }
    _handlingResult = true;
    unawaited(_scanner.stop());
    Navigator.of(context).pop(result);
  }

  void _showInvalidCode() {
    _errorTimer?.cancel();
    setState(() => _error = '二维码不是有效的收货地址码，请重新扫描');
    _errorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _error = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('tospino-address-scanner-page'),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            fit: BoxFit.cover,
            tapToFocus: true,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      color: Colors.white70,
                      size: 52,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      localizeMiniProgramLabel(context, '无法使用相机'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: TospinoText.strong,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizeMiniProgramLabel(
                        context,
                        '请允许相机权限后重试，或返回手动填写地址。',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: 0.28)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('tospino-address-scanner-close'),
                        tooltip: localizeMiniProgramLabel(context, '关闭'),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizeMiniProgramLabel(context, '扫描收货地址'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: TospinoText.strong,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  key: const Key('tospino-address-scanner-window'),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC9B1C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      localizeMiniProgramLabel(context, _error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  )
                else
                  Text(
                    localizeMiniProgramLabel(context, '将地址二维码放入框内，即可自动识别'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                    ),
                  ),
                const Spacer(),
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _scanner,
                  builder: (context, state, _) {
                    final torchOn = state.torchState == TorchState.on;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: IconButton.filledTonal(
                        key: const Key('tospino-address-scanner-torch'),
                        tooltip: localizeMiniProgramLabel(
                          context,
                          torchOn ? '关闭闪光灯' : '打开闪光灯',
                        ),
                        onPressed: _scanner.toggleTorch,
                        icon: Icon(
                          torchOn
                              ? Icons.flashlight_on_rounded
                              : Icons.flashlight_off_rounded,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
