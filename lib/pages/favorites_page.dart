import 'package:flutter/material.dart';

import '../models/app_car.dart';
import '../services/app_database.dart';
import '../widgets/hover_tap.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<AppCar>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = AppDatabase.instance.getFavoriteCars();
  }

  Future<void> _refresh() async {
    setState(() {
      _favoritesFuture = AppDatabase.instance.getFavoriteCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF020617),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<AppCar>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cars = snapshot.data!;
          if (cars.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet. Tap ❤️ on cars to save them.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              padding: const EdgeInsets.all(14),
              itemBuilder: (context, index) {
                final car = cars[index];
                return HoverTap(
                  borderRadius: BorderRadius.circular(16),
                  hoverColor: Colors.white.withOpacity(0.05),
                  child: Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car, color: Colors.white),
                      ),
                      title: Text(
                        '${car.brand} ${car.model}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        car.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '\$${car.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
