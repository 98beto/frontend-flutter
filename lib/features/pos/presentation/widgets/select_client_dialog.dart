import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';
import 'package:pos_desktop/features/clients/presentation/providers/clients_repository_provider.dart';

class ClientSelectionResult {
  const ClientSelectionResult({this.id, this.name, this.shouldClear = false});

  final int? id;
  final String? name;
  final bool shouldClear;

  factory ClientSelectionResult.pick({required int id, required String name}) {
    return ClientSelectionResult(id: id, name: name);
  }

  factory ClientSelectionResult.clear() {
    return const ClientSelectionResult(shouldClear: true);
  }
}

class SelectClientDialog extends ConsumerStatefulWidget {
  const SelectClientDialog({super.key});

  @override
  ConsumerState<SelectClientDialog> createState() => _SelectClientDialogState();
}

class _SelectClientDialogState extends ConsumerState<SelectClientDialog> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _search = '';
  int _currentPage = 1;
  int _lastPage = 1;
  final List<ClientRecord> _items = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(_loadInitial);
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
    if (!_scrollController.hasClients || _isLoading || _isLoadingMore) {
      return;
    }

    final position = _scrollController.position;
    if (_currentPage >= _lastPage) {
      return;
    }

    if (position.pixels >= position.maxScrollExtent - 180) {
      _loadNextPage();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
      _currentPage = 1;
      _lastPage = 1;
      _items.clear();
    });

    try {
      final response = await ref.read(clientsRepositoryProvider).getClients(
            page: 1,
            search: _search,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _items.addAll(response.items);
        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      final response = await ref.read(clientsRepositoryProvider).getClients(
            page: _currentPage + 1,
            search: _search,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _items.addAll(response.items);
        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.panel : AppTheme.lightBg0,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asignar cliente',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona un cliente para asociarlo a la venta actual.',
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        _search = value.trim();
                        _loadInitial();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Buscar cliente',
                        hintText: 'Nombre, email o telefono',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      _search = _searchController.text.trim();
                      _loadInitial();
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(ClientSelectionResult.clear()),
                icon: const Icon(Icons.person_off_rounded),
                label: const Text('Usar publico general'),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_errorMessage != null && _items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _loadInitial,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_items.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay clientes para mostrar.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= _items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = _items[index];
                        return _ClientOptionTile(item: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientOptionTile extends StatefulWidget {
  const _ClientOptionTile({required this.item});

  final ClientRecord item;

  @override
  State<_ClientOptionTile> createState() => _ClientOptionTileState();
}

class _ClientOptionTileState extends State<_ClientOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: AppTheme.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pop(
            ClientSelectionResult.pick(id: item.id, name: item.name),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tileBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  item.email?.trim().isNotEmpty == true ? item.email! : 'Sin correo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.phone?.trim().isNotEmpty == true ? item.phone! : 'Sin telefono',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
