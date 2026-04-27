import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import '../widgets/hover_tap.dart';

class SignOutPage extends StatelessWidget {
  const SignOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Sign Out'),
        backgroundColor: const Color(0xFF020617),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 64, color: Color(0xFF4A90E2)),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to sign out?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can sign in again anytime.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              HoverTap(
                onTap: () {
                  AuthService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                hoverColor: Colors.red.withOpacity(0.12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AuthService.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Sign Out Now'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
