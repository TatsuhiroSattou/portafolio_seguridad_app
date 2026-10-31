import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/connectivity_provider.dart';
import 'providers/requests_provider.dart';
import 'repositories/requests_repository.dart';
import 'screens/home_screen.dart';
import 'services/connectivity_service.dart';
import 'widgets/offline_banner.dart';

void main() {
  runApp(const BugTatsuApp());
}

class BugTatsuApp extends StatelessWidget {
  const BugTatsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (context) =>
              ConnectivityProvider(context.read<ConnectivityService>()),
        ),
        Provider<RequestsRepository>(create: (_) => RequestsRepository()),
        ChangeNotifierProxyProvider<ConnectivityProvider, RequestsProvider>(
          lazy: false,
          create: (context) => RequestsProvider(
            context.read<RequestsRepository>(),
          ),
          update: (context, connectivity, requests) {
            requests!.updateConnectivity(
              connectivity.isReady && connectivity.isOnline,
            );
            return requests;
          },
        ),
      ],
      child: _buildApp(),
    );
  }

  Widget _buildApp() {
    return MaterialApp(
      title: 'BugTatsu Sec',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) =>
          OfflineBannerHost(child: child ?? const SizedBox.shrink()),
      home: const HomeScreen(),
    );
  }
}
