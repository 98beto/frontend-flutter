import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';

final operationContextProvider = Provider<OperationContext>((ref) {
  final settings = ref.watch(settingsProvider);

  return OperationContext(
    branchId: settings.branchId,
    deviceIdentifier: settings.deviceIdentifier,
  );
});
