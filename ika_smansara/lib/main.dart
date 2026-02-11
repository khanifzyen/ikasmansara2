import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Step 1: WidgetsBinding initialized');

    // Initialize dependencies
    await configureDependencies();
    debugPrint('Step 2: Dependencies configured');

    // Initialize locale data for Indonesia
    await initializeDateFormatting('id', null);
    debugPrint('Step 4: Locale initialized');

    runApp(const IkaSmanSaraApp());
  } catch (e, stackTrace) {
    debugPrint('Initialization Error: $e');
    debugPrint('Stacktrace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Gagal inisialisasi aplikasi:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class IkaSmanSaraApp extends StatelessWidget {
  const IkaSmanSaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(LoadAppSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Lock to light theme only
          return MaterialApp.router(
            title: 'IKA SMANSARA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [Locale('id'), Locale('en')],
            builder: (context, child) {
              return UpgradeAlert(
                upgrader: Upgrader(
                  minAppVersion: '2.0.3',
                  debugLogging: true,
                  // debugDisplayAlways: true, // Uncomment untuk testing
                ),
                showIgnore: false,
                showLater: false,
                dialogStyle: UpgradeDialogStyle.cupertino,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
