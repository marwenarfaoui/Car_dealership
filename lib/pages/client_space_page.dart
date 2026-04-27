import 'package:flutter/material.dart';

import '../models/app_car.dart';
import '../services/app_database.dart';

class ClientSpacePage extends StatefulWidget {
  const ClientSpacePage({super.key});

  @override
  State<ClientSpacePage> createState() => _ClientSpacePageState();
}

class _ClientSpacePageState extends State<ClientSpacePage> {
  late Future<List<AppCar>> _carsFuture;
  late Future<Set<int>> _favoriteIdsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _refresh() async {
    setState(_reload);
  }

  void _reload() {
    _carsFuture = AppDatabase.instance.getCars();
    _favoriteIdsFuture = AppDatabase.instance.getFavoriteCarIds();
  }

  Future<void> _toggleFavorite(AppCar car) async {
    if (car.id == null) return;
    await AppDatabase.instance.toggleFavoriteCar(car.id!);
    if (!mounted) return;
    setState(() {
      _favoriteIdsFuture = AppDatabase.instance.getFavoriteCarIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Client Space'),
        backgroundColor: const Color(0xFF020617),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<AppCar>>(
        future: _carsFuture,
        builder: (context, carsSnapshot) {
          return FutureBuilder<Set<int>>(
            future: _favoriteIdsFuture,
            builder: (context, favSnapshot) {
              if (!carsSnapshot.hasData || !favSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final cars = carsSnapshot.data!;
              final favoriteIds = favSnapshot.data!;
              if (cars.isEmpty) {
                return const Center(child: Text('No cars available right now.'));
              }

              final favoriteCars =
                  cars.where((c) => c.id != null && favoriteIds.contains(c.id)).toList();
              final recommendedCars =
                  cars.where((c) => c.isFeatured || c.price >= 100000).take(8).toList();
              final recentCars = cars.reversed.take(8).toList();

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    _summaryStrip(
                      total: cars.length,
                      favorites: favoriteCars.length,
                      featured: cars.where((e) => e.isFeatured).length,
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('Recommended for you'),
                    const SizedBox(height: 10),
                    _horizontalCars(recommendedCars, favoriteIds),
                    const SizedBox(height: 16),
                    _sectionTitle('Recent cars'),
                    const SizedBox(height: 10),
                    _horizontalCars(recentCars, favoriteIds),
                    const SizedBox(height: 16),
                    _sectionTitle('All cars'),
                    const SizedBox(height: 8),
                    ...cars.map((car) {
                      final isFavorite = car.id != null && favoriteIds.contains(car.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4A90E2).withOpacity(0.15),
                            child: const Icon(Icons.directions_car),
                          ),
                          title: Text('${car.brand} ${car.model}'),
                          subtitle: Text('Stock: ${car.stock} • ${car.description}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${car.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _toggleFavorite(car),
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryStrip({required int total, required int favorites, required int featured}) {
    return Row(
      children: [
        Expanded(child: _metricCard('Cars', '$total', Icons.directions_car_outlined)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('Favorites', '$favorites', Icons.favorite_border)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('Featured', '$featured', Icons.workspace_premium_outlined)),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF113B7A)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
  }

  Widget _horizontalCars(List<AppCar> cars, Set<int> favoriteIds) {
    if (cars.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Text('No cars to display.'),
      );
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final car = cars[index];
          final isFavorite = car.id != null && favoriteIds.contains(car.id);
          return Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF123A7A), Color(0xFF2F7BF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        car.isFeatured ? 'Featured' : 'Popular',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _toggleFavorite(car),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${car.brand} ${car.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${car.price.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
