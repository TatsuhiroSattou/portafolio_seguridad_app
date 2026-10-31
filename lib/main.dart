import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/connectivity_provider.dart';
import 'providers/evidence_provider.dart';
import 'providers/requests_provider.dart';
import 'repositories/requests_repository.dart';
import 'screens/home_screen.dart';
import 'services/connectivity_service.dart';
import 'services/image_service.dart';
import 'services/permission_service.dart';
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
        Provider<PermissionService>(create: (_) => PermissionService()),
        Provider<ImageService>(create: (_) => ImageService()),
        ChangeNotifierProvider<EvidenceProvider>(
          create: (context) => EvidenceProvider(
            permissions: context.read<PermissionService>(),
            images: context.read<ImageService>(),
          ),
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
