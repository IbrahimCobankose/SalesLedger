/// Supabase Storage bucket adları. Tüm bucket'lar gizlidir (private);
/// görüntüleme için kısa ömürlü imzalı (signed) URL üretilir.
/// Tek kaynak olması için datasource'lar ve görsel widget'lar buradan okur.
abstract class StorageBuckets {
  static const productPhotos = 'product-photos';
  static const purchasePhotos = 'purchase-photos';
  static const avatars = 'avatars';
}

/// DB'de saklanan bir görsel değerini (yeni: göreli path, eski: tam public URL
/// veya imzalı URL) silme işlemi için bucket içi göreli path'e çevirir.
String storagePathFromValue(String value, String bucket) {
  for (final marker in ['/object/public/$bucket/', '/object/sign/$bucket/']) {
    final index = value.indexOf(marker);
    if (index != -1) {
      var rest = value.substring(index + marker.length);
      final query = rest.indexOf('?');
      if (query != -1) rest = rest.substring(0, query);
      return Uri.decodeComponent(rest);
    }
  }
  return value; // Zaten göreli path.
}
