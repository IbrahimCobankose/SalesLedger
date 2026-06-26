import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Görselleri yüklemeden önce WebP'e sıkıştırır. WebP, JPEG'e göre belirgin
/// şekilde daha az yer kaplar — Supabase ücretsiz katmanını korumak için.
///
/// Web platformunda yerel sıkıştırma eklentisi çalışmadığından orijinal (JPEG)
/// bytes korunur; sıkıştırma sırasında bir hata olursa da orijinale düşülür.
abstract class ImageCompressor {
  static const _quality = 80;

  /// Sıkıştırılan görselin dosya uzantısı (web'de JPEG kalır).
  static String get fileExtension => kIsWeb ? 'jpg' : 'webp';

  /// Storage'a yüklerken kullanılacak içerik türü.
  static String get contentType => kIsWeb ? 'image/jpeg' : 'image/webp';

  static Future<Uint8List> toWebp(Uint8List bytes) async {
    if (kIsWeb) return bytes;
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        format: CompressFormat.webp,
        quality: _quality,
      );
      return result.isEmpty ? bytes : Uint8List.fromList(result);
    } catch (_) {
      return bytes;
    }
  }
}
