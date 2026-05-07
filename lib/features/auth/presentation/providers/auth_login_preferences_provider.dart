import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_repository_provider.dart';

final authLastIdentifierProvider = Provider<String>((ref) {
  return ref.watch(authLocalDatasourceProvider).getLastIdentifier();
});
