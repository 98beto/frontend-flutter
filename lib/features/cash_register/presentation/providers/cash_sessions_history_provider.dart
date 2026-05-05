import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_register_repository_provider.dart';

final cashSessionsHistoryProvider =
    NotifierProvider<CashSessionsHistoryNotifier, CashSessionsHistoryState>(
  CashSessionsHistoryNotifier.new,
);

class CashSessionsHistoryNotifier extends Notifier<CashSessionsHistoryState> {
  @override
  CashSessionsHistoryState build() {
    Future.microtask(loadInitial);
    return const CashSessionsHistoryState();
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
      selectedSessionId: null,
    );

    try {
      final response = await ref.read(cashRegisterRepositoryProvider).getCashSessions(page: 1);

      state = state.copyWith(
        items: response.items,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        selectedSessionId: response.items.isEmpty ? null : response.items.first.id,
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
      final response = await ref.read(cashRegisterRepositoryProvider).getCashSessions(
            page: nextPage,
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

  void selectSession(int id) {
    state = state.copyWith(selectedSessionId: id);
  }

  Future<void> retry() async {
    await loadInitial();
  }
}

class CashSessionsHistoryState {
  const CashSessionsHistoryState({
    this.items = const [],
    this.selectedSessionId,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<CashSessionHistoryItem> items;
  final int? selectedSessionId;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  CashSessionHistoryItem? get selectedSession {
    for (final item in items) {
      if (item.id == selectedSessionId) {
        return item;
      }
    }
    return null;
  }

  CashSessionsHistoryState copyWith({
    List<CashSessionHistoryItem>? items,
    Object? selectedSessionId = _sentinel,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return CashSessionsHistoryState(
      items: items ?? this.items,
      selectedSessionId: identical(selectedSessionId, _sentinel)
          ? this.selectedSessionId
          : selectedSessionId as int?,
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
