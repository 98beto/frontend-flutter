import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

final cashSessionProvider = FutureProvider<CashSession?>((ref) async {
  return ref.watch(posRepositoryProvider).getCurrentCashSession();
});
