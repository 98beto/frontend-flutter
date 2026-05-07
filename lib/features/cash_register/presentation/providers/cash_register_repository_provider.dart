import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/cash_register/data/datasources/cash_register_remote_datasource.dart';
import 'package:pos_desktop/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:pos_desktop/features/cash_register/domain/repositories/cash_register_repository.dart';

final cashRegisterRemoteDatasourceProvider =
    Provider<CashRegisterRemoteDatasource>((ref) {
      return CashRegisterRemoteDatasource(ref.watch(dioProvider));
    });

final cashRegisterRepositoryProvider = Provider<CashRegisterRepository>((ref) {
  return CashRegisterRepositoryImpl(
    ref.watch(cashRegisterRemoteDatasourceProvider),
  );
});
