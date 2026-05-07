import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_register_actions_provider.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_session_movements_provider.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_session_movements_panel.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_session_history_dialog.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_session_status_card.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/close_cash_form.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/close_cash_result_card.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/open_cash_form.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_sessions_history_provider.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/withdraw_cash_form.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';

class CashRegisterPage extends ConsumerWidget {
  const CashRegisterPage({super.key});

  static const _desktopContentWidth = 1240.0;

  Future<void> _openCashSession(
    BuildContext context,
    WidgetRef ref,
    double openingBalance,
    String? notes,
  ) async {
    try {
      await ref
          .read(cashRegisterActionsProvider.notifier)
          .openCashSession(openingBalance: openingBalance, notes: notes);

      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Caja abierta correctamente',
            message: 'La sesion ya esta lista para operar.',
          );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible abrir la caja',
            message: error.message,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible abrir la caja',
            message: 'Verifica la informacion e intenta nuevamente.',
          );
    }
  }

  Future<void> _withdrawCash(
    BuildContext context,
    WidgetRef ref,
    int sessionId,
    double amount,
    String? notes,
  ) async {
    try {
      await ref
          .read(cashRegisterActionsProvider.notifier)
          .withdrawCash(sessionId: sessionId, amount: amount, notes: notes);

      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Retiro registrado',
            message:
                'La salida de efectivo se registro correctamente en la sesion.',
          );
      ref.invalidate(cashSessionMovementsProvider(sessionId));
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible registrar el retiro',
            message: error.message,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible registrar el retiro',
            message: 'Verifica la informacion e intenta nuevamente.',
          );
    }
  }

  Future<void> _closeCashSession(
    BuildContext context,
    WidgetRef ref,
    int sessionId,
    double closingBalance,
    String? notes,
  ) async {
    try {
      await ref
          .read(cashRegisterActionsProvider.notifier)
          .closeCashSession(
            sessionId: sessionId,
            closingBalance: closingBalance,
            notes: notes,
          );

      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Caja cerrada correctamente',
            message: 'El cierre se registro y el POS quedo bloqueado.',
          );
      ref.invalidate(cashSessionMovementsProvider(sessionId));
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible cerrar la caja',
            message: error.message,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible cerrar la caja',
            message: 'Verifica la informacion e intenta nuevamente.',
          );
    }
  }

  Future<void> _showCashSessionHistoryDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    ref.invalidate(cashSessionsHistoryProvider);
    return showDialog<void>(
      context: context,
      builder: (_) => const CashSessionHistoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashSessionAsync = ref.watch(cashSessionProvider);
    final actionsState = ref.watch(cashRegisterActionsProvider);
    final closeResult = actionsState.valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _desktopContentWidth),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: cashSessionAsync.when(
            loading: () => const Center(
              key: ValueKey('cash-register-loading'),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Card(
              key: const ValueKey('cash-register-error'),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No fue posible consultar la caja actual.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            data: (session) {
              final historyButton = Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _showCashSessionHistoryDialog(context, ref),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Ver historial de sesiones'),
                ),
              );

              if (closeResult != null) {
                return SingleChildScrollView(
                  key: const ValueKey('cash-register-close-result'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      historyButton,
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: CloseCashResultCard(
                            result: closeResult,
                            onAcknowledge: ref
                                .read(cashRegisterActionsProvider.notifier)
                                .clearCloseResult,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (session == null) {
                return SingleChildScrollView(
                  key: const ValueKey('cash-register-open-state'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      historyButton,
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OpenCashForm(
                                isSubmitting: actionsState.isLoading,
                                onSubmit: (openingBalance, notes) =>
                                    _openCashSession(
                                      context,
                                      ref,
                                      openingBalance,
                                      notes,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              const _CashRegisterInfoCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                key: const ValueKey('cash-register-open-session'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    historyButton,
                    const SizedBox(height: 20),
                    CashSessionStatusCard(session: session),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 24.0;
                        const withdrawWidth = 400.0;
                        final canShowSideBySide = constraints.maxWidth >= 960;

                        final withdrawForm = SizedBox(
                          width: canShowSideBySide
                              ? withdrawWidth
                              : double.infinity,
                          child: WithdrawCashForm(
                            isSubmitting: actionsState.isLoading,
                            onSubmit: (amount, notes) => _withdrawCash(
                              context,
                              ref,
                              session.id,
                              amount,
                              notes,
                            ),
                          ),
                        );

                        final closeForm = CloseCashForm(
                          isSubmitting: actionsState.isLoading,
                          onSubmit: (closingBalance, notes) =>
                              _closeCashSession(
                                context,
                                ref,
                                session.id,
                                closingBalance,
                                notes,
                              ),
                        );

                        if (canShowSideBySide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              withdrawForm,
                              const SizedBox(width: spacing),
                              Expanded(child: closeForm),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            withdrawForm,
                            const SizedBox(height: spacing),
                            closeForm,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 560,
                      child: CashSessionMovementsPanel(sessionId: session.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CashRegisterInfoCard extends StatelessWidget {
  const _CashRegisterInfoCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sin sesion activa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Abre una nueva caja para habilitar el cobro en POS y comenzar un nuevo turno.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _InfoPoint(
              icon: Icons.point_of_sale_rounded,
              title: 'POS bloqueado hasta abrir caja',
              description:
                  'El equipo no podra registrar ventas mientras no exista una sesion activa.',
            ),
            const SizedBox(height: 16),
            const _InfoPoint(
              icon: Icons.payments_outlined,
              title: 'Registra el monto inicial real',
              description:
                  'Ese valor se usara como referencia para el seguimiento del turno y el cierre.',
            ),
            const SizedBox(height: 16),
            const _InfoPoint(
              icon: Icons.outbox_rounded,
              title: 'Retiros durante la sesion',
              description:
                  'Con la caja abierta puedes registrar salidas manuales de efectivo sin cerrar la sesion.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPoint extends StatelessWidget {
  const _InfoPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
