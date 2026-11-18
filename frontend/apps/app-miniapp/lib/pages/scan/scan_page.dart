import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../localization.dart';
import '../common/page_theme.dart';

/// Opens the camera scanner and returns the first non-empty code it detects.
Future<String?> openScanner(BuildContext context) {
  return Navigator.of(context).push<String>(ScanPage.route());
}

/// Shows a scanned code in a reusable result sheet with a copy action.
Future<void> showScanResult(BuildContext context, String value) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ScanResultSheet(value: value),
  );
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  static Route<String> route() {
    return MaterialPageRoute<String>(builder: (_) => const ScanPage());
  }

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handlingResult = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingResult || !mounted) return;
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere((code) => code.isNotEmpty, orElse: () => '');
    if (value.isEmpty) return;

    _handlingResult = true;
    unawaited(_scanner.stop());
    Navigator.of(context).pop(value);
  }

  Future<void> _runScannerAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // The scanner error state already explains camera permission failures.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('scan-page'),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            fit: BoxFit.cover,
            tapToFocus: true,
            errorBuilder: (context, error) => _ScannerError(
              onRetry: () => unawaited(_runScannerAction(_scanner.start)),
            ),
          ),
          IgnorePointer(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('scan-close'),
                        tooltip: l10n.text('关闭', 'Close'),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.text('扫一扫', 'Scan'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: HostTypography.emphasis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  key: const Key('scan-frame'),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    l10n.text(
                      '将二维码或条码放入框内，即可自动识别',
                      'Place a QR code or barcode inside the frame',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _scanner,
                    builder: (context, state, _) {
                      final torchOn = state.torchState == TorchState.on;
                      final canSwitchCamera =
                          state.isInitialized &&
                          state.error == null &&
                          (state.availableCameras == null ||
                              state.availableCameras! > 1);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            key: const Key('scan-torch'),
                            tooltip: l10n.text(
                              torchOn ? '关闭闪光灯' : '打开闪光灯',
                              torchOn
                                  ? 'Turn flashlight off'
                                  : 'Turn flashlight on',
                            ),
                            onPressed:
                                state.torchState == TorchState.unavailable
                                ? null
                                : () => unawaited(
                                    _runScannerAction(_scanner.toggleTorch),
                                  ),
                            icon: Icon(
                              torchOn
                                  ? Icons.flashlight_on_rounded
                                  : Icons.flashlight_off_rounded,
                            ),
                          ),
                          const SizedBox(width: 18),
                          IconButton.filledTonal(
                            key: const Key('scan-switch-camera'),
                            tooltip: l10n.text('切换摄像头', 'Switch camera'),
                            onPressed: canSwitchCamera
                                ? () => unawaited(
                                    _runScannerAction(_scanner.switchCamera),
                                  )
                                : null,
                            icon: const Icon(Icons.cameraswitch_rounded),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Center(
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
                l10n.text('无法使用相机', 'Camera unavailable'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: HostTypography.emphasis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.text('请允许相机权限后重试', 'Allow camera access and try again'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('scan-retry'),
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.text('重试', 'Retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanResultSheet extends StatefulWidget {
  const _ScanResultSheet({required this.value});

  final String value;

  @override
  State<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<_ScanResultSheet> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        key: const Key('scan-result-sheet'),
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.text('扫描结果', 'Scan result'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: HostTypography.emphasis,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.value,
                  key: const Key('scan-result-value'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('scan-result-copy'),
                onPressed: _copy,
                icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
                label: Text(
                  _copied
                      ? l10n.text('已复制', 'Copied')
                      : l10n.text('复制内容', 'Copy'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
