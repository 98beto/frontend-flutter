import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/core/storage/shared_preferences_provider.dart';
import 'package:pos_desktop/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pos_desktop/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pos_desktop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_desktop/features/auth/domain/repositories/auth_repository.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(ref.watch(sharedPreferencesProvider));
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authLocalDatasourceProvider),
    ref.watch(authRemoteDatasourceProvider),
  );
});
