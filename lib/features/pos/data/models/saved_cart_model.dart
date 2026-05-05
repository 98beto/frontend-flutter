import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';

class SavedCartModel extends SavedCart {
  const SavedCartModel({
    required super.id,
    required super.name,
    required super.status,
    required super.discountAmount,
    required super.subtotal,
    required super.taxAmount,
    required super.totalAmount,
    required super.items,
    super.customerId,
    super.customerName,
    super.cashSessionId,
    super.notes,
  });

  factory SavedCartModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final cashSession = json['cash_session'] as Map<String, dynamic>?;
    final items = json['items'] as List<dynamic>? ?? const [];

    return SavedCartModel(
      id: '${json['id']}',
      name: json['name'] as String? ?? 'Carrito guardado',
      status: json['status'] as String? ?? 'saved',
      customerId: customer?['id'] as int?,
      customerName: customer?['name'] as String?,
      cashSessionId: cashSession?['id'] as int?,
      discountAmount: _toDouble(json['discount_amount']),
      subtotal: _toDouble(json['subtotal']),
      taxAmount: _toDouble(json['tax_amount']),
      totalAmount: _toDouble(json['total_amount']),
      notes: json['notes'] as String?,
      items: items
          .map((item) => _SavedCartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class _SavedCartItemModel extends CartItem {
  const _SavedCartItemModel({required super.product, required super.quantity});

  factory _SavedCartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>? ?? const {};

    final product = Product(
      id: '${productJson['id'] ?? json['product_id']}',
      name: productJson['name'] as String? ?? 'Producto sin nombre',
      sku: productJson['sku'] as String? ?? 'SIN-SKU',
      price: SavedCartModel._toDouble(json['unit_price']),
      stock: productJson['stock_quantity'] as int? ?? 0,
      category: (productJson['category'] as Map<String, dynamic>?)?['name']
              as String? ??
          'Sin categoria',
      categoryId: productJson['category_id'] as int?,
      barcode: productJson['barcode'] as String?,
      brand: (productJson['brand'] as Map<String, dynamic>?)?['name'] as String?,
      isActive: productJson['is_active'] as bool? ?? true,
    );

    return _SavedCartItemModel(
      product: product,
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}
