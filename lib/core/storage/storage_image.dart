import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sales_ledger/core/storage/signed_url_cache.dart';
import 'package:sales_ledger/core/storage/storage_buckets.dart';

/// Gizli bir bucket'taki görseli, [path] için imzalı URL üreterek gösterir.
///
/// [path] DB'de saklanan değerdir. Yeni kayıtlar bucket içi göreli path tutar;
/// geriye dönük uyumluluk için değer tam bir `http` URL ise doğrudan gösterilir.
/// Önbellek anahtarı stabil path olduğundan, imzalı URL yenilense bile görsel
/// yeniden indirilmez.
class StorageImage extends StatelessWidget {
  const StorageImage({
    super.key,
    required this.bucket,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String bucket;
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final ph = placeholder ?? const SizedBox.shrink();
    final err = errorWidget ?? const SizedBox.shrink();

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, _) => ph,
        errorWidget: (_, _, _) => err,
      );
    }

    return FutureBuilder<String>(
      future: SignedUrlCache.resolve(bucket, path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return ph;
        if (snapshot.hasError || snapshot.data == null) return err;
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          cacheKey: '$bucket::$path',
          fit: fit,
          width: width,
          height: height,
          placeholder: (_, _) => ph,
          errorWidget: (_, _, _) => err,
        );
      },
    );
  }
}

/// Profil avatarı için [CircleAvatar]. Avatar değeri (path) imzalı URL'ye
/// çevrilir; yokken veya yüklenirken [fallback] (genelde baş harf) gösterilir.
/// [overrideImage] verilirse (örn. yeni seçilen foto'nun [MemoryImage]'ı)
/// imzalı URL beklemeden o gösterilir.
class StorageAvatar extends StatelessWidget {
  const StorageAvatar({
    super.key,
    required this.radius,
    required this.path,
    this.overrideImage,
    this.backgroundColor,
    this.fallback,
  });

  final double radius;
  final String? path;
  final ImageProvider? overrideImage;
  final Color? backgroundColor;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (overrideImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: overrideImage,
      );
    }

    final value = path;
    if (value == null || value.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fallback,
      );
    }

    if (value.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: CachedNetworkImageProvider(value),
      );
    }

    return FutureBuilder<String>(
      future: SignedUrlCache.resolve(StorageBuckets.avatars, value),
      builder: (context, snapshot) {
        final url = snapshot.data;
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: url != null
              ? CachedNetworkImageProvider(url, cacheKey: 'avatars::$value')
              : null,
          child: url == null ? fallback : null,
        );
      },
    );
  }
}
