import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama genelinde geçerli dil tercihi (gereksinim 5.2). Varsayılan
/// Türkçe'dir; giriş sayfasındaki TR/EN seçici bu provider'ı günceller.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('tr');

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
