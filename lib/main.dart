import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/nhost_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Nhost
  await NhostService.initialize();

  runApp(
    const ProviderScope(
      child: ERPApp(),
    ),
  );
}

class ERPApp extends ConsumerWidget {
  const ERPApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Lumiere ERP',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
