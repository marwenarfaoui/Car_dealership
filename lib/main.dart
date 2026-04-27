import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';
import 'services/backend_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.initialize();
  try {
    await BackendSyncService.instance.syncFromBackend();
  } catch (_) {
    // Keep app startup resilient when backend is unavailable.
  }
  runApp(const CarDealershipApp());
}

class CarDealershipApp extends StatelessWidget {
  const CarDealershipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Dealership',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
