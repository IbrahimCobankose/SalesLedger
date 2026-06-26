import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// Kullanıcı [AppLimits.sessionInactivityTimeout] süresi boyunca ekranla hiç
/// etkileşmezse oturumu otomatik olarak sonlandırır ve giriş ekranına
/// yönlendirir (güvenlik gereksinimi). Tüm yönlendirilen sayfaları sarmalar;
/// her dokunuş/kaydırma sayacı sıfırlar. Sayaç yalnızca aktif oturum varken
/// çalışır.
class InactivityWatcher extends ConsumerStatefulWidget {
  const InactivityWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends ConsumerState<InactivityWatcher> {
  Timer? _timer;
  bool _signingOut = false;

  void _handleActivity([Object? _]) {
    // Oturum yoksa (giriş ekranı vb.) sayaca gerek yok.
    if (supabase.auth.currentSession == null) {
      _timer?.cancel();
      return;
    }
    _timer?.cancel();
    _timer = Timer(AppLimits.sessionInactivityTimeout, _onTimeout);
  }

  Future<void> _onTimeout() async {
    if (_signingOut || supabase.auth.currentSession == null) return;
    _signingOut = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = context.l10n.sessionExpiredMessage;
    try {
      await ref.read(signOutUseCaseProvider)();
      ref.read(selectedProfileProvider.notifier).clear();
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      // Çıkış başarısız olsa bile sayaç bir sonraki etkileşimde yeniden kurulur.
    } finally {
      _signingOut = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Oturum açıldığında sayacı başlat, kapandığında durdur.
    ref.listen(authStateProvider, (_, next) {
      if (next.valueOrNull?.session != null) {
        _handleActivity();
      } else {
        _timer?.cancel();
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleActivity,
      onPointerMove: _handleActivity,
      onPointerSignal: _handleActivity,
      child: widget.child,
    );
  }
}
