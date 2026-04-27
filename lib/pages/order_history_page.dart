import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFF020617),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Order History Page placeholder',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
