import 'package:sales_ledger/core/network/supabase_client.dart';

/// Gizli (private) bucket'lardaki dosyalar için kısa ömürlü imzalı URL üretir
/// ve bellekte önbelleğe alır.
///
/// DB'de fotoğraflar artık tam URL yerine bucket içi göreli **path** olarak
/// saklanır (örn. `<userId>/123.jpg`). Görüntüleme anında bu path imzalı URL'ye
/// çevrilir. İmzalı URL belirli süre geçerli olduğundan, gereksiz ağ
/// çağrılarını önlemek için süresi dolana kadar önbellekten yeniden kullanılır.
abstract class SignedUrlCache {
  /// İmzalı URL'nin sunucudaki geçerlilik süresi.
  static const _ttl = Duration(hours: 1);

  /// Önbellekten yeniden kullanım süresi (TTL'den biraz kısa tutulur ki
  /// kullanım anında süresi dolmuş bir URL elde edilmesin).
  static const _reuse = Duration(minutes: 50);

  static final Map<String, _Entry> _cache = {};

  /// [bucket] içindeki [path] için imzalı URL döndürür. Geçerli bir önbellek
  /// varsa onu kullanır, yoksa yeni imzalı URL üretip önbelleğe alır.
  static Future<String> resolve(String bucket, String path) async {
    final key = '$bucket::$path';
    final cached = _cache[key];
    if (cached != null && cached.validUntil.isAfter(DateTime.now())) {
      return cached.url;
    }
    final url = await supabase.storage.from(bucket).createSignedUrl(
          path,
          _ttl.inSeconds,
        );
    _cache[key] = _Entry(url, DateTime.now().add(_reuse));
    return url;
  }

  /// Oturum kapanışında vb. önbelleği temizler.
  static void clear() => _cache.clear();
}

class _Entry {
  _Entry(this.url, this.validUntil);
  final String url;
  final DateTime validUntil;
}
