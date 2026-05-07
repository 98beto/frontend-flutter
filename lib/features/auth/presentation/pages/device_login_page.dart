import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_actions_provider.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_login_preferences_provider.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_repository_provider.dart';

class DeviceLoginPage extends ConsumerStatefulWidget {
  const DeviceLoginPage({super.key});

  @override
  ConsumerState<DeviceLoginPage> createState() => _DeviceLoginPageState();
}

class _DeviceLoginPageState extends ConsumerState<DeviceLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _secretController = TextEditingController();
  final _identifierFocusNode = FocusNode();
  final _secretFocusNode = FocusNode();

  bool _obscureSecret = true;
  bool _didSeedIdentifier = false;
  String? _identifierError;
  String? _secretError;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_handleIdentifierChanged);
    _secretController.addListener(_handleSecretChanged);
  }

  @override
  void dispose() {
    _identifierController.removeListener(_handleIdentifierChanged);
    _secretController.removeListener(_handleSecretChanged);
    _identifierController.dispose();
    _secretController.dispose();
    _identifierFocusNode.dispose();
    _secretFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsProvider);
    final lastIdentifier = ref.watch(authLastIdentifierProvider);

    if (!_didSeedIdentifier) {
      _identifierController.text = lastIdentifier;
      _didSeedIdentifier = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _LoginBrand(),
                  const SizedBox(height: 32),
                  _LoginFormCard(
                    formKey: _formKey,
                    identifierController: _identifierController,
                    secretController: _secretController,
                    identifierFocusNode: _identifierFocusNode,
                    secretFocusNode: _secretFocusNode,
                    obscureSecret: _obscureSecret,
                    identifierError: _identifierError,
                    secretError: _secretError,
                    submitError: _submitError,
                    isLoading: authState.isLoading,
                    onToggleSecret: () {
                      setState(() {
                        _obscureSecret = !_obscureSecret;
                      });
                    },
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 24),
                  const _LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _identifierError = null;
      _secretError = null;
      _submitError = null;
    });

    try {
      await ref
          .read(authLocalDatasourceProvider)
          .saveLastIdentifier(_identifierController.text);

      await ref
          .read(authActionsProvider.notifier)
          .login(
            identifier: _identifierController.text,
            secret: _secretController.text,
          );

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();
      _secretController.clear();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _identifierError = _resolveFieldError(error.errors, 'identifier');
        _secretError = _resolveFieldError(error.errors, 'secret');
        _submitError = _resolveSubmitError(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitError =
            'No fue posible iniciar sesion. Verifica la conexion e intenta nuevamente.';
      });
    }
  }

  void _handleIdentifierChanged() {
    if (_identifierError == null && _submitError == null) {
      return;
    }

    setState(() {
      _identifierError = null;
      _submitError = null;
    });
  }

  void _handleSecretChanged() {
    if (_secretError == null && _submitError == null) {
      return;
    }

    setState(() {
      _secretError = null;
      _submitError = null;
    });
  }

  String? _resolveFieldError(Map<String, dynamic>? errors, String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return null;
  }

  String _resolveSubmitError(ApiException error) {
    if (error.errors != null && error.errors!.isNotEmpty) {
      final firstEntry = error.errors!.entries.first;
      final firstValue = firstEntry.value;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first.toString();
      }
    }

    return error.message;
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.point_of_sale_rounded,
            color: accentColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sistema de inventario',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Punto de venta · Inventario · Caja',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'El acceso queda vinculado al dispositivo hasta cerrar sesion.',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.formKey,
    required this.identifierController,
    required this.secretController,
    required this.identifierFocusNode,
    required this.secretFocusNode,
    required this.obscureSecret,
    required this.identifierError,
    required this.secretError,
    required this.submitError,
    required this.isLoading,
    required this.onToggleSecret,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController secretController;
  final FocusNode identifierFocusNode;
  final FocusNode secretFocusNode;
  final bool obscureSecret;
  final String? identifierError;
  final String? secretError;
  final String? submitError;
  final bool isLoading;
  final VoidCallback onToggleSecret;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? AppTheme.bg0 : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar sesion',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Ingresa las credenciales asignadas a este dispositivo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if ((submitError ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _LoginErrorBanner(message: submitError!),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: identifierController,
              focusNode: identifierFocusNode,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              forceErrorText: identifierError,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Identificador',
                hintText: 'POS-01',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Ingresa el identificador del dispositivo.';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(secretFocusNode);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: secretController,
              focusNode: secretFocusNode,
              obscureText: obscureSecret,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              forceErrorText: secretError,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Secreto',
                hintText: 'secret-123',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: onToggleSecret,
                  icon: Icon(
                    obscureSecret
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Ingresa el secreto del dispositivo.';
                }
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(isLoading ? 'Conectando...' : 'Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginErrorBanner extends StatelessWidget {
  const _LoginErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.bgRed : AppTheme.lightBgRed;
    final borderColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: borderColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
