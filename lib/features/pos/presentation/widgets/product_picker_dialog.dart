import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/pos/domain/entities/category.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/presentation/providers/categories_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/quantity_picker_dialog.dart';

class ProductPickerDialog extends ConsumerStatefulWidget {
  const ProductPickerDialog({super.key});

  @override
  ConsumerState<ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends ConsumerState<ProductPickerDialog> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
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
      ref.read(productsProvider.notifier).loadNextPage();
    }
  }

  void _showStockWarning(Product product) {
    ref.read(appNotificationProvider.notifier).showWarning(
      title: 'Stock insuficiente',
      message:
          'Solo hay ${product.stock} unidades disponibles de ${product.name}.',
    );
  }

  void _showAddedSuccess(Product product, int quantity) {
    ref.read(appNotificationProvider.notifier).showSuccess(
      title: 'Producto agregado',
      message: '${product.name} x$quantity agregado al carrito.',
    );
  }

  Future<void> _addProductQuick(Product product) async {
    if (product.stock <= 0) {
      _showStockWarning(product);
      return;
    }

    final wasAdded = ref.read(posProvider.notifier).addProduct(product);
    if (!wasAdded) {
      _showStockWarning(product);
      return;
    }

    _showAddedSuccess(product, 1);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addProductWithQuantity(Product product) async {
    if (product.stock <= 0) {
      _showStockWarning(product);
      return;
    }

    final requestedQuantity = await showDialog<int>(
      context: context,
      builder: (_) => QuantityPickerDialog(
        title: 'Agregar cantidad',
        subtitle: product.name,
        confirmLabel: 'Agregar al carrito',
        maxQuantity: product.stock,
      ),
    );

    if (!mounted || requestedQuantity == null) {
      return;
    }

    final wasAdded = ref.read(posProvider.notifier).addProduct(
          product,
          quantity: requestedQuantity,
        );

    if (!wasAdded) {
      _showStockWarning(product);
      return;
    }

    _showAddedSuccess(product, requestedQuantity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
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
                            'Seleccionar producto',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Haz clic en una tarjeta para agregar 1 unidad o usa el boton de cantidad para capturar un monto mayor.',
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
                TextField(
                  onChanged: ref.read(productsProvider.notifier).setSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Buscar producto...',
                  ),
                ),
                const SizedBox(height: 22),
                categoriesAsync.when(
                  data: (categories) => _CategoryFilters(
                    categories: categories,
                    selectedCategoryId: productsState.selectedCategoryId,
                    onSelected: ref.read(productsProvider.notifier).setCategory,
                  ),
                  loading: () => const SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (error, stackTrace) => Text(
                    'No fue posible cargar las categorias.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: _ProductsContent(
                    state: productsState,
                    scrollController: _scrollController,
                    onRetry: ref.read(productsProvider.notifier).loadInitial,
                    onAddProduct: _addProductQuick,
                    onAddProductWithQuantity: _addProductWithQuantity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatefulWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  @override
  State<_CategoryFilters> createState() => _CategoryFiltersState();
}

class _CategoryFiltersState extends State<_CategoryFilters> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  void didUpdateWidget(covariant _CategoryFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollState)
      ..dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final canScrollLeft = position.pixels > 0;
    final canScrollRight = position.pixels < position.maxScrollExtent;

    if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
    }
  }

  Future<void> _scrollBy(double offset) async {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final target = (position.pixels + offset).clamp(0.0, position.maxScrollExtent);

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScrollArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canScrollLeft,
          onPressed: () => _scrollBy(-220),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Stack(
            children: [
              SizedBox(
                height: 42,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.categories.length + 1,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? null : widget.categories[index - 1];
                    final selected = isAll
                        ? widget.selectedCategoryId == null
                        : widget.selectedCategoryId == category!.id;

                    return ChoiceChip(
                      label: Text(isAll ? 'Todas' : category!.name),
                      selected: selected,
                      onSelected: (_) => widget.onSelected(
                        isAll ? null : category!.id,
                      ),
                    );
                  },
                ),
              ),
              if (_canScrollLeft)
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: _ScrollFade(alignment: Alignment.centerLeft),
                  ),
                ),
              if (_canScrollRight)
                const Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: _ScrollFade(alignment: Alignment.centerRight),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _ScrollArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canScrollRight,
          onPressed: () => _scrollBy(220),
        ),
      ],
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = enabled
        ? (isDark ? AppTheme.bg1 : AppTheme.lightBg1)
        : (isDark ? AppTheme.bg2 : AppTheme.lightBg2);
    final foregroundColor = enabled
        ? theme.colorScheme.onSurface
        : textTheme.bodyMedium?.color ?? AppTheme.muted;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _ScrollFade extends StatelessWidget {
  const _ScrollFade({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fadeColor = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final begin = alignment == Alignment.centerLeft
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final end = alignment == Alignment.centerLeft
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      width: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            fadeColor,
            AppTheme.transparent,
          ],
        ),
      ),
    );
  }
}

class _ProductsContent extends StatelessWidget {
  const _ProductsContent({
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onAddProduct,
    required this.onAddProductWithQuantity,
  });

  final ProductsState state;
  final ScrollController scrollController;
  final Future<void> Function() onRetry;
  final ValueChanged<Product> onAddProduct;
  final ValueChanged<Product> onAddProductWithQuantity;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron productos para la busqueda actual.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            itemCount: state.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) {
              final product = state.items[index];
              return _ProductCard(
                product: product,
                onAddProduct: () => onAddProduct(product),
                onAddProductWithQuantity: () => onAddProductWithQuantity(product),
              );
            },
          ),
        ),
        if (state.isLoadingMore) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (state.errorMessage != null && state.items.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(state.errorMessage!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.onAddProduct,
    required this.onAddProductWithQuantity,
  });

  final Product product;
  final VoidCallback onAddProduct;
  final VoidCallback onAddProductWithQuantity;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stock <= 0;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final hoverOverlayColor = isDark
        ? AppTheme.accent.withValues(alpha: 0.05)
        : AppTheme.lightAccent.withValues(alpha: 0.04);
    final defaultBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final hoverBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final borderColor = _isHovered && !isOutOfStock
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.10);
    final categoryBackground = isDark
        ? AppTheme.soft.withValues(alpha: 0.35)
        : AppTheme.lightBgBlue;
    final categoryTextColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;
    final ctaBackground = isOutOfStock
        ? (isDark ? AppTheme.bg4 : AppTheme.lightBg4)
        : (isDark ? AppTheme.purple : AppTheme.lightBrand);
    final ctaTextColor = isOutOfStock
        ? (textTheme.bodyMedium?.color ?? AppTheme.muted)
        : (isDark ? AppTheme.black : AppTheme.lightBase00);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        hoverColor: AppTheme.transparent,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? hoverOverlayColor
              : null,
        ),
        onTap: isOutOfStock ? null : widget.onAddProduct,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered && !isOutOfStock ? -2 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isHovered && !isOutOfStock ? hoverBackground : defaultBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: _isHovered && !isOutOfStock
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: categoryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                    Text(
                      product.sku,
                      style: TextStyle(
                        color: textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(product.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                isOutOfStock
                    ? 'Sin existencias disponibles'
                    : 'Stock disponible: ${product.stock}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isOutOfStock ? AppTheme.danger : null,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: isOutOfStock ? null : widget.onAddProductWithQuantity,
                    icon: const Icon(Icons.tag_rounded, size: 16),
                    label: const Text('Cantidad'),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ctaBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isOutOfStock ? 'Agotado' : 'Agregar',
                      style: TextStyle(
                        color: ctaTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
