import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';
import 'package:pos_desktop/features/clients/presentation/providers/clients_repository_provider.dart';

final clientsProvider = NotifierProvider<ClientsNotifier, ClientsState>(
  ClientsNotifier.new,
);

class ClientsNotifier extends Notifier<ClientsState> {
  @override
  ClientsState build() {
    Future.microtask(loadInitial);
    return const ClientsState();
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
      final response = await ref
          .read(clientsRepositoryProvider)
          .getClients(page: 1, search: state.search);

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
          .read(clientsRepositoryProvider)
          .getClients(page: nextPage, search: state.search);

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

class ClientsState {
  const ClientsState({
    this.items = const [],
    this.search = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<ClientRecord> items;
  final String search;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;

  ClientsState copyWith({
    List<ClientRecord>? items,
    String? search,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return ClientsState(
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
