import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_database.dart';
import 'backend_config.dart';

class BackendSyncService {
  BackendSyncService._();

  static final BackendSyncService instance = BackendSyncService._();

  Future<void> syncFromBackend() async {
    if (!BackendConfig.isEnabled) return;

    await _syncCars();
  }

  Future<void> _syncCars() async {
    final uri = Uri.parse('${BackendConfig.apiBaseUrl}/cars');
    final response = await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return;
    }

    final decoded = jsonDecode(response.body);
    List<dynamic> rows;

    if (decoded is List) {
      rows = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      rows = decoded['data'] as List<dynamic>;
    } else {
      return;
    }

    final cars = rows.whereType<Map<String, dynamic>>().toList();
    if (cars.isEmpty) return;

    await AppDatabase.instance.upsertCarsFromBackend(cars);
  }
}
