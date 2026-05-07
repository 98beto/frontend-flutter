import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';
import 'package:pos_desktop/features/clients/presentation/providers/client_actions_provider.dart';
import 'package:pos_desktop/features/clients/presentation/providers/clients_provider.dart';
import 'package:pos_desktop/features/clients/presentation/widgets/client_form_dialog.dart';
import 'package:pos_desktop/features/clients/presentation/widgets/clients_cards_grid.dart';
import 'package:pos_desktop/features/clients/presentation/widgets/clients_filters_bar.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
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
      ref.read(clientsProvider.notifier).loadNextPage();
    }
  }

  Future<void> _openClientForm([ClientRecord? client]) async {
    final request = await showDialog<ClientUpsertRequestModel>(
      context: context,
      builder: (_) => ClientFormDialog(initialClient: client),
    );

    if (!mounted || request == null) {
      return;
    }

    try {
      final notifier = ref.read(clientActionsProvider.notifier);
      final savedClient = client == null
          ? await notifier.createClient(request)
          : await notifier.updateClient(client.id, request);

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: client == null ? 'Cliente creado' : 'Cliente actualizado',
            message:
                '${savedClient.name} ya forma parte de tu cartera comercial.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: client == null
                ? 'No fue posible crear el cliente'
                : 'No fue posible actualizar el cliente',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: client == null
                ? 'No fue posible crear el cliente'
                : 'No fue posible actualizar el cliente',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  Future<void> _confirmDelete(ClientRecord client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar cliente'),
          content: Text(
            'Se eliminara ${client.name}. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await ref.read(clientActionsProvider.notifier).deleteClient(client.id);

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Cliente eliminado',
            message: '${client.name} fue eliminado del catalogo comercial.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el cliente',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el cliente',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  String _resolveApiErrorMessage(ApiException error) {
    if (error.errors == null || error.errors!.isEmpty) {
      return error.message;
    }

    final firstEntry = error.errors!.entries.first;
    final firstValue = firstEntry.value;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientsProvider);

    _searchController.value = _searchController.value.copyWith(
      text: state.search,
      selection: TextSelection.collapsed(offset: state.search.length),
      composing: TextRange.empty,
    );

    return Column(
      children: [
        ClientsFiltersBar(
          searchController: _searchController,
          total: state.total,
          onSearchSubmitted: (value) {
            ref.read(clientsProvider.notifier).setSearch(value);
          },
          onClearFilters: () {
            _searchController.clear();
            ref.read(clientsProvider.notifier).clearFilters();
          },
          onCreateClient: _openClientForm,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ClientsCardsGrid(
              items: state.items,
              total: state.total,
              isLoadingInitial: state.isLoadingInitial,
              isLoadingMore: state.isLoadingMore,
              errorMessage: state.errorMessage,
              hasMore: state.hasMore,
              onRetry: ref.read(clientsProvider.notifier).loadInitial,
              onEdit: _openClientForm,
              onDelete: _confirmDelete,
            ),
          ),
        ),
      ],
    );
  }
}
