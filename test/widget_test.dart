import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/core/storage/shared_preferences_provider.dart';
import 'package:pos_desktop/features/auth/data/models/device_session_model.dart';
import 'package:pos_desktop/main.dart';
import 'package:pos_desktop/features/pos/data/models/sale_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';
import 'package:pos_desktop/features/pos/domain/entities/category.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/domain/entities/sale_result.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';
import 'package:pos_desktop/features/pos/domain/repositories/pos_repository.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders POS shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      DeviceSessionModel.tokenKey: 'test-token',
      DeviceSessionModel.deviceIdKey: 1,
      DeviceSessionModel.branchIdKey: 1,
      DeviceSessionModel.deviceNameKey: 'Caja 1',
      DeviceSessionModel.deviceIdentifierKey: 'POS-01',
      DeviceSessionModel.branchNameKey: 'Sucursal Centro',
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          posRepositoryProvider.overrideWithValue(_FakePosRepository()),
        ],
        child: const PosDesktopApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Punto de Venta'), findsOneWidget);
    expect(find.text('Carrito actual'), findsOneWidget);
    expect(find.text('Resumen de venta'), findsOneWidget);
  });
}

class _FakePosRepository implements PosRepository {
  @override
  Future<SavedCart> createSavedCart(SavedCartRequestModel request) {
    throw UnimplementedError();
  }

  @override
  Future<SaleResult> createSale(SaleRequestModel request) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSavedCart(String id) async {}

  @override
  Future<CashSession?> getCurrentCashSession() async => null;

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    return const PaginatedResponse(
      items: [],
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    );
  }

  @override
  Future<PaginatedResponse<SavedCart>> getSavedCarts() async {
    return const PaginatedResponse(
      items: [],
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    );
  }

  @override
  Future<SavedCart> recoverSavedCart(String id) {
    throw UnimplementedError();
  }

  @override
  Future<SavedCart> updateSavedCart(String id, SavedCartRequestModel request) {
    throw UnimplementedError();
  }
}
