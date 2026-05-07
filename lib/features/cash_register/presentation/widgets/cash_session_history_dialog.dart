import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_sessions_history_provider.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_session_history_detail.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_sessions_history_list.dart';

class CashSessionHistoryDialog extends ConsumerWidget {
  const CashSessionHistoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashSessionsHistoryProvider);
    final notifier = ref.read(cashSessionsHistoryProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de sesiones',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Consulta sesiones anteriores y revisa sus movimientos de caja.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 380,
                      child: CashSessionsHistoryList(
                        items: state.items,
                        selectedSessionId: state.selectedSessionId,
                        isLoadingInitial: state.isLoadingInitial,
                        isLoadingMore: state.isLoadingMore,
                        errorMessage: state.errorMessage,
                        hasMore: state.hasMore,
                        onSelectSession: notifier.selectSession,
                        onRetry: notifier.retry,
                        onLoadMore: notifier.loadNextPage,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: CashSessionHistoryDetail(
                        session: state.selectedSession,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
