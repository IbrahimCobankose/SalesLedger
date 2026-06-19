import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sales_ledger/app.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle (assets klasöründen)
  await dotenv.load(fileName: '.env');

  // Supabase bağlantısını başlat
  await initSupabase();

  runApp(const MyApp());
}