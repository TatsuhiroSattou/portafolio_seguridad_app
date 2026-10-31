import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/connectivity_provider.dart';
import 'providers/evidence_provider.dart';
import 'providers/requests_provider.dart';
import 'repositories/requests_repository.dart';
import 'repositories/evidence_repository.dart';
import 'screens/home_screen.dart';
import 'services/connectivity_service.dart';
import 'services/image_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.init();
  runApp(BugTatsuApp(notifications: notifications));
}

class BugTatsuApp extends StatelessWidget {
  const BugTatsuApp({super.key, required this.notifications});

  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notifications),
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
        Provider<EvidenceRepository>(create: (_) => EvidenceRepository()),
        ChangeNotifierProvider<EvidenceProvider>(
          create: (context) => EvidenceProvider(
            permissions: context.read<PermissionService>(),
            images: context.read<ImageService>(),
            repository: context.read<EvidenceRepository>(),
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
