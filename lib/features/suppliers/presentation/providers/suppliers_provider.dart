import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';
import 'package:pos_desktop/features/suppliers/presentation/providers/suppliers_repository_provider.dart';

final suppliersProvider = NotifierProvider<SuppliersNotifier, SuppliersState>(
  SuppliersNotifier.new,
);

class SuppliersNotifier extends Notifier<SuppliersState> {
  @override
  SuppliersState build() {
    Future.microtask(loadInitial);
    return const SuppliersState();
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
      total: 0,
      items: const [],
    );

    try {
      final response = await ref.read(suppliersRepositoryProvider).getSuppliers(
            page: 1,
            search: state.search,
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
      final response = await ref.read(suppliersRepositoryProvider).getSuppliers(
            page: nextPage,
            search: state.search,
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

  Future<void> clearFilters() async {
    state = state.copyWith(search: '');
    await loadInitial();
  }
}

class SuppliersState {
  const SuppliersState({
    this.items = const [],
    this.search = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<SupplierRecord> items;
  final String search;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  SuppliersState copyWith({
    List<SupplierRecord>? items,
    String? search,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return SuppliersState(
      items: items ?? this.items,
      search: search ?? this.search,
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
