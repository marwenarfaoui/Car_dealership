import 'package:flutter/material.dart';

import '../models/app_car.dart';
import 'cart_page.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../widgets/car_image.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.car});

  final AppCar car;

  @override
  Widget build(BuildContext context) {
    final imagePath = (car.imageUrl ?? '').trim();
    final hasImage = imagePath.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        foregroundColor: Colors.white,
        title: const Text('Car Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: hasImage
                    ? CarImage(
                        source: imagePath,
                        fit: BoxFit.contain,
                        placeholder: const Center(
                          child: Icon(Icons.directions_car_filled, color: Colors.white70, size: 64),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.directions_car_filled, color: Colors.white70, size: 64),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${car.brand} ${car.model}',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${car.price.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Stock: ${car.stock}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Text(
              car.description,
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Car Details',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _detailRow('Year Model', (car.yearModel ?? '').trim().isEmpty ? 'N/A' : car.yearModel!),
                  _detailRow('Kilometrage', car.kilometrage == null ? 'N/A' : '${car.kilometrage} km'),
                  _detailRow('Motorisation', (car.motorisation ?? '').trim().isEmpty ? 'N/A' : car.motorisation!),
                  _detailRow('Color', (car.color ?? '').trim().isEmpty ? 'N/A' : car.color!),
                  _detailRow(
                    'Consumption (100km)',
                    car.consumptionPer100km == null
                        ? 'N/A'
                        : '${car.consumptionPer100km!.toStringAsFixed(1)} L/100km',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: AuthService.currentUser,
              builder: (context, user, _) {
                final isClient = user != null && !user.isAdmin;
                if (!isClient) return const SizedBox.shrink();
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: car.stock > 0
                        ? () {
                            CartService.setCarQuantity(car, 1);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartPage()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(car.stock > 0 ? 'Purchase Now' : 'Out of Stock'),
                  ),
                );
              },
            ),
              if (car.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Featured Car',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
