import 'package:flutter/material.dart';

import 'platform_style.dart';

void showPlatformToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformStyle.controlRadius),
        ),
      ),
    );
}

Future<bool> showPlatformConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = '取消',
  String confirmLabel = '确认',
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      )
                    : null,
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<void> showPlatformSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionLabel = '完成',
  VoidCallback? onDone,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.check_circle_rounded, size: 48, color: scheme.primary),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDone?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      );
    },
  );
}
