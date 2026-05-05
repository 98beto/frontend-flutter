import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_repository_provider.dart';

final inventoryMovementsProvider =
    NotifierProvider<InventoryMovementsNotifier, InventoryMovementsState>(
  InventoryMovementsNotifier.new,
);

class InventoryMovementsNotifier extends Notifier<InventoryMovementsState> {
  @override
  InventoryMovementsState build() {
    Future.microtask(loadInitial);
    return const InventoryMovementsState();
  }

  Future<void> loadInitial() async {
    if (state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(
      isLoadingInitial: true,
      isLoadingMore: false,
      errorMessage: null,
      currentPage: 1,
      lastPage: 1,
      items: const [],
    );

    try {
      final response = await ref.read(inventoryRepositoryProvider).getMovements(
            page: 1,
            productId: state.productId,
            type: state.type,
            source: state.source,
          );

      state = state.copyWith(
        items: response.items,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        isLoadingInitial: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await ref.read(inventoryRepositoryProvider).getMovements(
            page: nextPage,
            productId: state.productId,
            type: state.type,
            source: state.source,
          );

      state = state.copyWith(
        items: [...state.items, ...response.items],
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> setProductId(int? value) async {
    state = state.copyWith(productId: value);
    await loadInitial();
  }

  Future<void> setType(String? value) async {
    state = state.copyWith(type: value);
    await loadInitial();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(productId: null, type: null, source: null);
    await loadInitial();
  }

  Future<void> setSource(String? value) async {
    state = state.copyWith(source: value);
    await loadInitial();
  }
}

class InventoryMovementsState {
  const InventoryMovementsState({
    this.items = const [],
    this.productId,
    this.type,
    this.source,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<InventoryMovement> items;
  final int? productId;
  final String? type;
  final String? source;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  InventoryMovementsState copyWith({
    List<InventoryMovement>? items,
    Object? productId = _sentinel,
    Object? type = _sentinel,
    Object? source = _sentinel,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return InventoryMovementsState(
      items: items ?? this.items,
      productId: identical(productId, _sentinel) ? this.productId : productId as int?,
      type: identical(type, _sentinel) ? this.type : type as String?,
      source: identical(source, _sentinel) ? this.source : source as String?,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();
