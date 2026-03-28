import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketcrm/core/router/router.dart';
import 'package:pocketcrm/core/theme/app_theme.dart';
import 'package:pocketcrm/core/theme/theme_provider.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocketcrm/core/notifications/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pocketcrm/core/config/app_config.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = kDebugMode
          ? ''
          : AppConfig.glitchtipDsn; // disabilitato in debug
      options.tracesSampleRate = 1.0;
      options.debug = false;
    },
    appRunner: () async {
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      await NotificationService().initialize();

      final appDocDir = await getApplicationSupportDirectory();
      if (kDebugMode) print('Hive storage path: ${appDocDir.path}');
      Hive.init(appDocDir.path);

      final box = await Hive.openBox<String>('app_storage');
      if (kDebugMode) {
        print('Hive box keys at startup: ${box.keys.toList()}');
      }

      await initializeDateFormatting('it_IT', null);

      runApp(
        ProviderScope(
          overrides: [hiveStorageBoxProvider.overrideWithValue(box)],
          child: const PocketCRMApp(),
        ),
      );

      // Rimuoviamo lo splash screen una volta che l'app è pronta
      FlutterNativeSplash.remove();
    },
  );
}

class PocketCRMApp extends ConsumerWidget {
  const PocketCRMApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialNotificationRoute != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (navigatorKey.currentContext != null) {
            navigatorKey.currentContext!.go(initialNotificationRoute!);
            clearInitialNotificationRoute();
          }
        });
      }
    });

    return MaterialApp.router(
      title: 'TwentyMobileCRM',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
