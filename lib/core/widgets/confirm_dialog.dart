import 'package:flutter/material.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';

/// Geri alınamaz işlemler (silme vb.) öncesinde kullanıcı onayı alır.
abstract class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = true,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel ?? l10n.commonDismiss),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? colorScheme.error : colorScheme.primary,
            ),
            child: Text(confirmLabel ?? l10n.commonDelete),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
