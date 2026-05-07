import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

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
      errorMessage: null,
      currentPage: 1,
      lastPage: 1,
      items: const [],
    );

    try {
      final response = await ref
          .read(posRepositoryProvider)
          .getProducts(
            page: 1,
            search: state.search,
            categoryId: state.selectedCategoryId,
          );

      state = state.copyWith(
        items: response.items,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        isLoadingInitial: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await loadInitial();
  }

  Future<void> setCategory(int? categoryId) async {
    state = state.copyWith(selectedCategoryId: categoryId);
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await ref
          .read(posRepositoryProvider)
          .getProducts(
            page: nextPage,
            search: state.search,
            categoryId: state.selectedCategoryId,
          );

      state = state.copyWith(
        items: [...state.items, ...response.items],
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }
}

class ProductsState {
  const ProductsState({
    this.items = const [],
    this.search = '',
    this.selectedCategoryId,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Product> items;
  final String search;
  final int? selectedCategoryId;
  final int currentPage;
  final int lastPage;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  ProductsState copyWith({
    List<Product>? items,
    String? search,
    Object? selectedCategoryId = _sentinel,
    int? currentPage,
    int? lastPage,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return ProductsState(
      items: items ?? this.items,
      search: search ?? this.search,
      selectedCategoryId: identical(selectedCategoryId, _sentinel)
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();
