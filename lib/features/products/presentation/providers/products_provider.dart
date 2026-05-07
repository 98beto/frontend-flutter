import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_repository_provider.dart';

final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    Future.microtask(loadInitial);
    return const ProductsState();
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
      final response = await ref
          .read(productsRepositoryProvider)
          .getProducts(
            page: 1,
            search: state.search,
            categoryId: state.categoryId,
            isAvailable: state.isAvailable,
            lowStockOnly: state.lowStockOnly,
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
      final response = await ref
          .read(productsRepositoryProvider)
          .getProducts(
            page: nextPage,
            search: state.search,
            categoryId: state.categoryId,
            isAvailable: state.isAvailable,
            lowStockOnly: state.lowStockOnly,
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

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await loadInitial();
  }

  Future<void> setCategoryId(int? value) async {
    state = state.copyWith(categoryId: value);
    await loadInitial();
  }

  Future<void> setIsAvailable(bool? value) async {
    state = state.copyWith(isAvailable: value);
    await loadInitial();
  }

  Future<void> setLowStockOnly(bool value) async {
    state = state.copyWith(lowStockOnly: value);
    await loadInitial();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      search: '',
      categoryId: null,
      isAvailable: null,
      lowStockOnly: false,
    );
    await loadInitial();
  }
}

class ProductsState {
  const ProductsState({
    this.items = const [],
    this.search = '',
    this.categoryId,
    this.isAvailable,
    this.lowStockOnly = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<ProductRecord> items;
  final String search;
  final int? categoryId;
  final bool? isAvailable;
  final bool lowStockOnly;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  ProductsState copyWith({
    List<ProductRecord>? items,
    String? search,
    Object? categoryId = _sentinel,
    Object? isAvailable = _sentinel,
    bool? lowStockOnly,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return ProductsState(
      items: items ?? this.items,
      search: search ?? this.search,
      categoryId: identical(categoryId, _sentinel)
          ? this.categoryId
          : categoryId as int?,
      isAvailable: identical(isAvailable, _sentinel)
          ? this.isAvailable
          : isAvailable as bool?,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
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
