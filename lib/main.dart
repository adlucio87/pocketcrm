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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Hive nella directory dei dati applicazione (persistente)
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
}

class PocketCRMApp extends ConsumerWidget {
  const PocketCRMApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TwentyMobile',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
