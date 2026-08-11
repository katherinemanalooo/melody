import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody/core/routes/app_router.dart';
import 'package:melody/core/theme/app_theme.dart';
import 'package:melody/providers/app/theme_provider.dart';

class MelodyApp extends ConsumerWidget {
  const MelodyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final ThemeMode themeMode =
    ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Melody',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: AppRouter.router,
    );
  }
}