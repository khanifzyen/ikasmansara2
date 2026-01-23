import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/network/pocketbase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  await dotenv.load(fileName: ".env");

  // Initialize Date Formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize PocketBase Service
  await PocketBaseService().init();

  runApp(const ProviderScope(child: IkasmansaraApp()));
}
