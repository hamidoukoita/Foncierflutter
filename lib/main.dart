import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/notifications/notifications_systeme.dart';
import 'package:flutter_mobile_prospect_agent/core/router/app_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsSysteme.initialiser();
  runApp(const ProviderScope(child: FoncierApp()));
}

class FoncierApp extends ConsumerWidget {
  const FoncierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Foncier+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
