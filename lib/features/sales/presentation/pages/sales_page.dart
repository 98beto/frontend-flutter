import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sales_provider.dart';
import 'package:pos_desktop/features/sales/presentation/widgets/sale_detail_dialog.dart';
import 'package:pos_desktop/features/sales/presentation/widgets/sales_filters_bar.dart';
import 'package:pos_desktop/features/sales/presentation/widgets/sales_list.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(salesProvider.notifier).loadNextPage();
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final state = ref.read(salesProvider);
    final initialDate = isFrom
        ? state.dateFrom ?? DateTime.now()
        : state.dateTo ?? DateTime.now();
    final theme = Theme.of(context);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final baseTheme = theme;
        return Theme(
          data: baseTheme.copyWith(
            datePickerTheme: baseTheme.datePickerTheme.copyWith(
              backgroundColor: baseTheme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selected == null) {
      return;
    }

    await ref.read(salesProvider.notifier).setDateRange(
          from: isFrom ? selected : state.dateFrom,
          to: isFrom ? state.dateTo : selected,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesProvider);
    _searchController.value = _searchController.value.copyWith(
      text: state.search,
      selection: TextSelection.collapsed(offset: state.search.length),
      composing: TextRange.empty,
    );

    return Column(
      children: [
        SalesFiltersBar(
          searchController: _searchController,
          selectedPaymentMethod: state.paymentMethod,
          dateFrom: state.dateFrom,
          dateTo: state.dateTo,
          onSearchSubmitted: (value) {
            ref.read(salesProvider.notifier).setSearch(value);
          },
          onPaymentMethodChanged: (value) {
            ref.read(salesProvider.notifier).setPaymentMethod(value);
          },
          onPickDateFrom: () => _pickDate(isFrom: true),
          onPickDateTo: () => _pickDate(isFrom: false),
          onClearFilters: () {
            _searchController.clear();
            ref.read(salesProvider.notifier).clearFilters();
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SalesList(
            items: state.items,
            scrollController: _scrollController,
            isLoadingInitial: state.isLoadingInitial,
            isLoadingMore: state.isLoadingMore,
            errorMessage: state.errorMessage,
            onRetry: ref.read(salesProvider.notifier).loadInitial,
            onOpenDetail: (sale) {
              showDialog<void>(
                context: context,
                builder: (_) => SaleDetailDialog(saleId: sale.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
