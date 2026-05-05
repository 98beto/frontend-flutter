import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/widgets/app_sidebar.dart';

final appSectionProvider = StateProvider<AppSection>((ref) => AppSection.pos);
