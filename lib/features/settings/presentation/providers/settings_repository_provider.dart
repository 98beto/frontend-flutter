import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/storage/shared_preferences_provider.dart';
import 'package:pos_desktop/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:pos_desktop/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:pos_desktop/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pos_desktop/features/settings/domain/repositories/settings_repository.dart';

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((
  ref,
) {
  return SettingsLocalDatasource(ref.watch(sharedPreferencesProvider));
});

final settingsRemoteDatasourceProvider = Provider<SettingsRemoteDatasource>((
  ref,
) {
  return const SettingsRemoteDatasource();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.watch(settingsLocalDatasourceProvider),
    ref.watch(settingsRemoteDatasourceProvider),
  );
});
