import 'dart:async';

import 'package:sales_ledger/core/constants/app_limits.dart';

/// Arama alanlarında her tuş vuruşunda sorgu atılmasını önler
/// (gereksinim 3.4 — arama alanlarında debounce ≥300 ms).
class Debouncer {
  Debouncer({this.duration = AppLimits.searchDebounce});

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() => _timer?.cancel();
}
