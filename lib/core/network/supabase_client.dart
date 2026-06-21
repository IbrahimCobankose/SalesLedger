import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sales_ledger/core/network/secure_session_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase istemcisini başlatır.
/// Bu fonksiyon [main()] içinde çağrılmalıdır.
///
/// .env dosyasındaki değerleri okur — bu değerlerin asla
/// kaynak koduna sabit (hardcode) yazılmaması gerekir.
Future<void> initSupabase() async {
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  assert(
    url != null && url.isNotEmpty,
    'SUPABASE_URL .env dosyasında tanımlı değil!',
  );
  assert(
    anonKey != null && anonKey.isNotEmpty,
    'SUPABASE_ANON_KEY .env dosyasında tanımlı değil!',
  );

  await Supabase.initialize(
    url: url!,
    anonKey: anonKey!,
    debug: kDebugMode, // Sadece debug modda Supabase loglarını göster
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(),
    ),
  );
}

/// Uygulama genelinde kullanılabilecek kısayol erişimci.
/// Örnek: `supabase.from('sales').select()`
final supabase = Supabase.instance.client;