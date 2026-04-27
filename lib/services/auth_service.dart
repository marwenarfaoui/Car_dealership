import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'app_database.dart';

class AuthService {
  AuthService._();

  static final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  static bool get isSignedIn => currentUser.value != null;

  static Future<void> initialize() async {
    await AppDatabase.instance.init();
  }

  static Future<bool> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.length < 6) {
      return false;
    }

    final user = await AppDatabase.instance.signIn(email.trim(), password);
    if (user == null) return false;
    currentUser.value = user;
    return true;
  }

  static Future<void> register({required AppUser user, required String password}) async {
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    final exists = await AppDatabase.instance.emailExists(user.email);
    if (exists) {
      throw ArgumentError('An account with this email already exists');
    }

    final created = await AppDatabase.instance.createUser(user, password);
    currentUser.value = created;
  }

  static Future<void> updateProfile(AppUser updatedUser) async {
    await AppDatabase.instance.updateUser(updatedUser);
    currentUser.value = updatedUser;
  }

  static void signOut() {
    currentUser.value = null;
  }

  static Future<List<AppUser>> getAllUsers() {
    return AppDatabase.instance.getAllUsers();
  }
}
