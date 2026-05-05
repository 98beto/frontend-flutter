import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_sessions_history_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movements_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/low_stock_products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_carts_provider.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sales_provider.dart';
import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_connection_provider.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _desktopContentWidth = 1180.0;
  static const _twoColumnBreakpoint = 1100.0;

  final _formKey = GlobalKey<FormState>();
  final _branchIdController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _deviceIdentifierController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _apiBaseUrlController = TextEditingController();
  final _defaultTaxRateController = TextEditingController();

  String _defaultPaymentMethod = 'cash';
  String _themeMode = 'system';
  bool _didSeedForm = false;
  bool _isSyncingForm = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _branchIdController.addListener(_handleDraftChanged);
    _branchNameController.addListener(_handleDraftChanged);
    _deviceIdentifierController.addListener(_handleDraftChanged);
    _deviceNameController.addListener(_handleDraftChanged);
    _defaultTaxRateController.addListener(_handleDraftChanged);
    _apiBaseUrlController.addListener(_handleApiUrlChanged);
  }

  @override
  void dispose() {
    _branchIdController.removeListener(_handleDraftChanged);
    _branchNameController.removeListener(_handleDraftChanged);
    _deviceIdentifierController.removeListener(_handleDraftChanged);
    _deviceNameController.removeListener(_handleDraftChanged);
    _defaultTaxRateController.removeListener(_handleDraftChanged);
    _apiBaseUrlController.removeListener(_handleApiUrlChanged);
    _branchIdController.dispose();
    _branchNameController.dispose();
    _deviceIdentifierController.dispose();
    _deviceNameController.dispose();
    _apiBaseUrlController.dispose();
    _defaultTaxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final connectionState = ref.watch(settingsConnectionProvider);

    if (!_didSeedForm) {
      _seedForm(settings);
    }

    final hasChanges = _buildDraft() != settings;
    final canSave = !_isSaving && hasChanges;

    final operationCard = _SettingsCard(
      title: 'Operacion',
      subtitle: 'Identifica esta caja dentro de la operacion actual.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _branchIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Branch ID'),
            validator: _validateBranchId,
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'ID numerico de la sucursal usada por ventas, caja e inventario. Debe existir en la API.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _branchNameController,
            decoration: const InputDecoration(labelText: 'Nombre de sucursal'),
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'Nombre descriptivo local para identificar esta caja.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _deviceIdentifierController,
            decoration: const InputDecoration(labelText: 'ID del dispositivo'),
            validator: _validateDeviceIdentifier,
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'Se envia a la API para identificar esta caja. Ejemplo: POS-01',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _deviceNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre visible del equipo',
            ),
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'Nombre mostrado dentro de la aplicacion.',
          ),
        ],
      ),
    );

    final connectionCard = _SettingsCard(
      title: 'Conexion',
      subtitle: 'Configura la comunicacion con el backend.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _apiBaseUrlController,
            decoration: const InputDecoration(labelText: 'API Base URL'),
            validator: _validateApiBaseUrl,
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'Direccion base del backend para consultas y operaciones del sistema.',
          ),
          const SizedBox(height: 20),
          _ConnectionStatusCard(state: connectionState),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: connectionState.isTesting ? null : () => _testConnection(context),
              icon: connectionState.isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering_rounded),
              label: const Text('Probar conexion'),
            ),
          ),
        ],
      ),
    );

    final saleCard = _SettingsCard(
      title: 'Venta',
      subtitle: 'Parametros base para el flujo de cobro.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _defaultTaxRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Impuesto por defecto (%)',
            ),
            validator: _validateTaxRate,
          ),
          const SizedBox(height: 8),
          const _FieldHint(
            'Porcentaje base usado para calcular impuestos en el POS.',
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _defaultPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Metodo de pago por defecto',
            ),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Efectivo')),
              DropdownMenuItem(value: 'card', child: Text('Tarjeta')),
              DropdownMenuItem(
                value: 'transfer',
                child: Text('Transferencia'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _defaultPaymentMethod = value;
              });
            },
          ),
        ],
      ),
    );

    final appearanceCard = _SettingsCard(
      title: 'Apariencia',
      subtitle: 'Preferencias visuales de la aplicacion.',
      child: DropdownButtonFormField<String>(
        initialValue: _themeMode,
        decoration: const InputDecoration(labelText: 'Tema'),
        items: const [
          DropdownMenuItem(value: 'light', child: Text('Claro')),
          DropdownMenuItem(value: 'dark', child: Text('Oscuro')),
          DropdownMenuItem(value: 'system', child: Text('Sistema')),
        ],
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _themeMode = value;
          });
        },
      ),
    );

    final systemCard = _SettingsCard(
      title: 'Sistema',
      subtitle: 'Informacion general y diagnostico rapido.',
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          _InfoLine(label: 'Version de la app', value: '1.0.0+1'),
          _InfoLine(label: 'Branch ID actual', value: '${settings.branchId}'),
          _InfoLine(
            label: 'Device ID actual',
            value: settings.deviceIdentifier,
          ),
          _InfoLine(label: 'API actual', value: settings.apiBaseUrl),
          _InfoLine(
            label: 'Estado de conexion',
            value: _connectionLabel(connectionState),
          ),
        ],
      ),
    );

    final actions = Row(
      children: [
        OutlinedButton(
          onPressed: _isSaving ? null : _resetForm,
          child: const Text('Restablecer'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: canSave ? () => _saveSettings(context) : null,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar cambios'),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _desktopContentWidth),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= _twoColumnBreakpoint;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (useTwoColumns) ...[
                      _TwoColumnRow(left: operationCard, right: connectionCard),
                      const SizedBox(height: 20),
                      _TwoColumnRow(left: saleCard, right: appearanceCard),
                    ] else ...[
                      operationCard,
                      const SizedBox(height: 20),
                      connectionCard,
                      const SizedBox(height: 20),
                      saleCard,
                      const SizedBox(height: 20),
                      appearanceCard,
                    ],
                    const SizedBox(height: 20),
                    systemCard,
                    const SizedBox(height: 24),
                    actions,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _seedForm(AppSettings settings) {
    _isSyncingForm = true;
    _branchIdController.text = '${settings.branchId}';
    _branchNameController.text = settings.branchName;
    _deviceIdentifierController.text = settings.deviceIdentifier;
    _deviceNameController.text = settings.deviceName;
    _apiBaseUrlController.text = settings.apiBaseUrl;
    _defaultTaxRateController.text = settings.defaultTaxRate.toStringAsFixed(2);
    _defaultPaymentMethod = settings.defaultPaymentMethod;
    _themeMode = settings.themeMode;
    _didSeedForm = true;
    _isSyncingForm = false;
  }

  void _handleDraftChanged() {
    if (!mounted || _isSyncingForm) {
      return;
    }

    setState(() {});
  }

  void _handleApiUrlChanged() {
    if (_isSyncingForm) {
      return;
    }

    ref.read(settingsConnectionProvider.notifier).markAsUntested();
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  AppSettings _buildDraft() {
    return AppSettings(
      branchId: int.tryParse(_branchIdController.text.trim()) ?? 0,
      branchName: _branchNameController.text.trim(),
      deviceIdentifier: _deviceIdentifierController.text.trim(),
      deviceName: _deviceNameController.text.trim(),
      apiBaseUrl: _normalizeBaseUrl(_apiBaseUrlController.text),
      defaultTaxRate: double.tryParse(_defaultTaxRateController.text.trim()) ?? -1,
      defaultPaymentMethod: _defaultPaymentMethod,
      themeMode: _themeMode,
    );
  }

  Future<void> _testConnection(BuildContext context) async {
    if (_validateApiBaseUrl(_apiBaseUrlController.text) != null) {
      _formKey.currentState?.validate();
      ref.read(appNotificationProvider.notifier).showWarning(
        title: 'URL invalida',
        message: 'Ingresa una URL valida para probar la conexion.',
      );
      return;
    }

    await ref
        .read(settingsConnectionProvider.notifier)
        .testConnection(_apiBaseUrlController.text);

    if (!mounted) {
      return;
    }

    final state = ref.read(settingsConnectionProvider);
    switch (state.type) {
      case SettingsConnectionStateType.success:
        ref.read(appNotificationProvider.notifier).showSuccess(
          title: 'Conexion verificada',
          message: 'La API respondio correctamente.',
        );
        break;
      case SettingsConnectionStateType.failure:
        ref.read(appNotificationProvider.notifier).showError(
          title: 'No fue posible conectar con la API',
          message: state.message,
        );
        break;
      case SettingsConnectionStateType.invalidUrl:
        ref.read(appNotificationProvider.notifier).showWarning(
          title: 'URL invalida',
          message: state.message,
        );
        break;
      case SettingsConnectionStateType.idle:
      case SettingsConnectionStateType.testing:
        break;
    }
  }

  Future<void> _saveSettings(BuildContext context) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ref.read(appNotificationProvider.notifier).showWarning(
        title: 'Revisa los campos marcados',
        message: 'Corrige los valores antes de guardar los cambios.',
      );
      return;
    }

    final previousSettings = ref.read(settingsProvider);
    final nextSettings = _buildDraft();

    setState(() {
      _isSaving = true;
    });

    ref.read(settingsProvider.notifier).saveSettings(nextSettings);

    ref.invalidate(dioProvider);
    ref.invalidate(cashSessionProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(savedCartsProvider);
    ref.invalidate(salesProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(inventoryMovementsProvider);
    ref.invalidate(lowStockProductsProvider);
    ref.invalidate(cashSessionsHistoryProvider);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ref.read(appNotificationProvider.notifier).showSuccess(
      title: 'Configuracion guardada',
      message: 'Los cambios ya estan disponibles en esta caja.',
    );

    if (previousSettings.branchId != nextSettings.branchId ||
        previousSettings.deviceIdentifier != nextSettings.deviceIdentifier ||
        previousSettings.apiBaseUrl != nextSettings.apiBaseUrl) {
      ref.read(appNotificationProvider.notifier).showInfo(
        title: 'Contexto operativo actualizado',
        message: 'La app recargara caja, ventas y catalogos con la nueva configuracion.',
      );
    }
  }

  void _resetForm() {
    final defaults = ref.read(settingsProvider.notifier).resetSettings();
    _seedForm(defaults);
    ref.read(settingsConnectionProvider.notifier).markAsUntested();
    setState(() {});

    ref.invalidate(dioProvider);
    ref.invalidate(cashSessionProvider);

    ref.read(appNotificationProvider.notifier).showInfo(
      title: 'Configuracion restablecida',
      message: 'Se restauraron los valores predeterminados.',
    );
  }

  String? _validateBranchId(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'El Branch ID es obligatorio y debe ser mayor a 0.';
    }

    return null;
  }

  String? _validateDeviceIdentifier(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'El ID del dispositivo es obligatorio.';
    }

    return null;
  }

  String? _validateApiBaseUrl(String? value) {
    final normalized = _normalizeBaseUrl(value);
    final uri = Uri.tryParse(normalized);
    if (normalized.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Ingresa una URL valida. Ejemplo: http://127.0.0.1:8000/api';
    }

    return null;
  }

  String? _validateTaxRate(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0 || parsed > 100) {
      return 'Ingresa un valor entre 0 y 100.';
    }

    return null;
  }

  String _normalizeBaseUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  String _connectionLabel(SettingsConnectionState state) {
    switch (state.type) {
      case SettingsConnectionStateType.idle:
        return 'Sin probar';
      case SettingsConnectionStateType.testing:
        return 'Probando';
      case SettingsConnectionStateType.success:
        return 'Conectado';
      case SettingsConnectionStateType.failure:
        return 'Sin respuesta';
      case SettingsConnectionStateType.invalidUrl:
        return 'URL invalida';
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  const _TwoColumnRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 20),
        Expanded(child: right),
      ],
    );
  }
}

class _FieldHint extends StatelessWidget {
  const _FieldHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  const _ConnectionStatusCard({required this.state});

  final SettingsConnectionState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color) = switch (state.type) {
      SettingsConnectionStateType.idle => ('Sin probar', AppTheme.grey),
      SettingsConnectionStateType.testing => (
        'Probando...',
        isDark ? AppTheme.brand : AppTheme.lightBrand,
      ),
      SettingsConnectionStateType.success => (
        'Conectado',
        isDark ? AppTheme.success : AppTheme.lightSuccess,
      ),
      SettingsConnectionStateType.failure => (
        'Sin respuesta',
        isDark ? AppTheme.danger : AppTheme.lightDanger,
      ),
      SettingsConnectionStateType.invalidUrl => (
        'URL invalida',
        isDark ? AppTheme.warning : AppTheme.lightWarning,
      ),
    };

    final description = switch (state.type) {
      SettingsConnectionStateType.idle => 'Ultima prueba: Sin pruebas recientes',
      SettingsConnectionStateType.testing => 'Ultima prueba: Verificando respuesta del servidor...',
      SettingsConnectionStateType.success =>
        'Ultima prueba: ${_formatRelative(state.lastCheckedAt)}',
      SettingsConnectionStateType.failure => 'Ultima prueba: Error en la ultima verificacion',
      SettingsConnectionStateType.invalidUrl =>
        'Ultima prueba: Corrige la direccion antes de intentar de nuevo',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bg1 : AppTheme.lightBg1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if ((state.message ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(state.message!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  static String _formatRelative(DateTime? value) {
    if (value == null) {
      return 'Sin pruebas recientes';
    }

    final difference = DateTime.now().difference(value);
    if (difference.inSeconds < 60) {
      return 'hace unos segundos';
    }
    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    }

    return 'hace ${difference.inHours} h';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value.trim().isEmpty ? 'No configurado' : value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
