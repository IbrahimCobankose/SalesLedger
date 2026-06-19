import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan standart snackbar.
/// Başarı (yeşil) ve hata (kırmızı) durumları destekler.
abstract class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required bool isError,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Varsa önceki snackbar'ı kapat
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: isError ? colorScheme.onError : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? colorScheme.onError : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? colorScheme.error : const Color(0xFF1B7F4A),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}