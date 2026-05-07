import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_session_provider.dart';

final operationContextProvider = Provider<OperationContext>((ref) {
  final session = ref.watch(authSessionProvider);

  return OperationContext(deviceIdentifier: session?.deviceIdentifier ?? '');
});
