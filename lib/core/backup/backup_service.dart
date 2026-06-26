import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';

/// Kullanıcının tüm verilerini tek bir JSON dosyasına dışa aktarır (yedek).
///
/// Salt dışa aktarmadır: veriler bozulmaz, geri yükleme yapılmaz. Amaç,
/// kullanıcının verilerinin yerel bir kopyasını saklayabilmesi/taşıyabilmesidir.
/// Fotoğraflar Supabase Storage'da kalır; yedeğe görseller dahil edilmez
/// (yalnızca veritabanı kayıtları). Satış/alım kalemleri ilgili kayıtların
/// altında iç içe (nested) yer alır.
abstract class BackupService {
  /// Geriye yedek dosyasının tam yolunu döndürür.
  static Future<String> exportAll() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const AppException('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    final userId = user.id;

    final data = <String, dynamic>{
      'format': 'sales_ledger_backup',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'user_id': userId,
      'profiles': await supabase.from('profiles').select().eq('user_id', userId),
      'products': await supabase.from('products').select().eq('user_id', userId),
      'customers': await supabase.from('customers').select().eq('user_id', userId),
      'suppliers': await supabase.from('suppliers').select().eq('user_id', userId),
      'sales':
          await supabase.from('sales').select('*, sale_items(*)').eq('user_id', userId),
      'purchases': await supabase
          .from('purchases')
          .select('*, purchase_items(*)')
          .eq('user_id', userId),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/satis_defteri_yedek_$timestamp.json');
    await file.writeAsString(jsonString, flush: true);

    return file.path;
  }
}
