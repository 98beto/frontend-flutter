import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_list_item.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sales_repository_provider.dart';

final salesProvider = NotifierProvider<SalesNotifier, SalesState>(
  SalesNotifier.new,
);

class SalesNotifier extends Notifier<SalesState> {
  @override
  SalesState build() {
    Future.microtask(loadInitial);
    return const SalesState();
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
          .read(salesRepositoryProvider)
          .getSales(
            page: 1,
            search: state.search,
            paymentMethod: state.paymentMethod,
            dateFrom: state.dateFrom,
            dateTo: state.dateTo,
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

  Future<void> loadNextPage() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await ref
          .read(salesRepositoryProvider)
          .getSales(
            page: nextPage,
            search: state.search,
            paymentMethod: state.paymentMethod,
            dateFrom: state.dateFrom,
            dateTo: state.dateTo,
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

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await loadInitial();
  }

  Future<void> setPaymentMethod(String? value) async {
    state = state.copyWith(paymentMethod: value);
    await loadInitial();
  }

  Future<void> setDateRange({DateTime? from, DateTime? to}) async {
    state = state.copyWith(dateFrom: from, dateTo: to);
    await loadInitial();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      search: '',
      paymentMethod: null,
      dateFrom: null,
      dateTo: null,
    );
    await loadInitial();
  }
}

class SalesState {
  const SalesState({
    this.items = const [],
    this.search = '',
    this.paymentMethod,
    this.dateFrom,
    this.dateTo,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<SaleListItem> items;
  final String search;
  final String? paymentMethod;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int currentPage;
  final int lastPage;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  SalesState copyWith({
    List<SaleListItem>? items,
    String? search,
    Object? paymentMethod = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    int? currentPage,
    int? lastPage,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return SalesState(
      items: items ?? this.items,
      search: search ?? this.search,
      paymentMethod: identical(paymentMethod, _sentinel)
          ? this.paymentMethod
          : paymentMethod as String?,
      dateFrom: identical(dateFrom, _sentinel)
          ? this.dateFrom
          : dateFrom as DateTime?,
      dateTo: identical(dateTo, _sentinel) ? this.dateTo : dateTo as DateTime?,
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
