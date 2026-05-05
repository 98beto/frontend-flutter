import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/storage/shared_preferences_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/widgets/app_shell.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

const _desktopInitialWindowSize = Size(1320, 840);
const _desktopMinimumWindowSize = Size(1180, 760);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (_supportsDesktopWindowManagement) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: _desktopInitialWindowSize,
      minimumSize: _desktopMinimumWindowSize,
      center: true,
      title: 'Sistema de Inventario',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(_desktopMinimumWindowSize);
      await windowManager.show();
      await windowManager.maximize();
      await windowManager.focus();
    });
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const PosDesktopApp(),
    ),
  );
}

class PosDesktopApp extends ConsumerWidget {
  const PosDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Inventario',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _resolveThemeMode(settings.themeMode),
      home: const AppShell(),
    );
  }

  ThemeMode _resolveThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

bool get _supportsDesktopWindowManagement =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;
