# Flutter ve eklentiler için R8/ProGuard kuralları.
# Flutter motoru zaten gerekli kuralları içerir; burada üçüncü taraf
# kütüphanelerin reflection ile eriştiği sınıfları koruyoruz.

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Supabase / OkHttp / Ktor istemcileri (yansıma ile kullanılabilir)
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# image_picker / path_provider gibi eklentiler — uyarıları sustur
-dontwarn com.google.errorprone.annotations.**
