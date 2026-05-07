import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_movement.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_register_repository_provider.dart';

final cashSessionMovementsProvider =
    NotifierProvider.family<
      CashSessionMovementsNotifier,
      CashSessionMovementsState,
      int
    >(CashSessionMovementsNotifier.new);

class CashSessionMovementsNotifier
    extends FamilyNotifier<CashSessionMovementsState, int> {
  @override
  CashSessionMovementsState build(int sessionId) {
    Future.microtask(loadInitial);
    return const CashSessionMovementsState();
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
      total: 0,
    );

    try {
      final response = await ref
          .read(cashRegisterRepositoryProvider)
          .getCashMovements(
            arg,
            page: 1,
            type: state.type,
            category: state.category,
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
      final response = await ref
          .read(cashRegisterRepositoryProvider)
          .getCashMovements(
            arg,
            page: nextPage,
            type: state.type,
            category: state.category,
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

  Future<void> setType(String? value) async {
    state = state.copyWith(type: value);
    await loadInitial();
  }

  Future<void> setCategory(String? value) async {
    state = state.copyWith(category: value);
    await loadInitial();
  }

  Future<void> setSource(String? value) async {
    state = state.copyWith(source: value);
    await loadInitial();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(type: null, category: null, source: null);
    await loadInitial();
  }
}

class CashSessionMovementsState {
  const CashSessionMovementsState({
    this.items = const [],
    this.type,
    this.category,
    this.source,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<CashMovement> items;
  final String? type;
  final String? category;
  final String? source;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  CashSessionMovementsState copyWith({
    List<CashMovement>? items,
    Object? type = _sentinel,
    Object? category = _sentinel,
    Object? source = _sentinel,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return CashSessionMovementsState(
      items: items ?? this.items,
      type: identical(type, _sentinel) ? this.type : type as String?,
      category: identical(category, _sentinel)
          ? this.category
          : category as String?,
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
