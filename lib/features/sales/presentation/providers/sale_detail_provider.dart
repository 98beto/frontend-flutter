import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_detail.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sales_repository_provider.dart';

final saleDetailProvider = FutureProvider.family<SaleDetail, int>((
  ref,
  saleId,
) async {
  return ref.watch(salesRepositoryProvider).getSaleById(saleId);
});
