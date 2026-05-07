import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_repository_provider.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  AppSettings saveSettings(AppSettings settings) {
    final savedSettings = ref
        .read(settingsRepositoryProvider)
        .saveSettings(settings);
    state = savedSettings;
    return savedSettings;
  }

  AppSettings resetSettings() {
    final defaults = ref.read(settingsRepositoryProvider).resetSettings();
    state = defaults;
    return defaults;
  }
}
