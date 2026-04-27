import 'package:flutter/material.dart';

import '../models/app_car.dart';

class CartItem {
  final AppCar car;
  final int quantity;

  const CartItem({required this.car, required this.quantity});

  CartItem copyWith({AppCar? car, int? quantity}) {
    return CartItem(
      car: car ?? this.car,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toCheckoutMap() {
    return {
      'id': (car.id ?? '${car.brand}-${car.model}').toString(),
      'title': car.model,
      'brand': car.brand,
      'price': car.price,
      'quantity': quantity,
      'image': Icons.directions_car,
    };
  }
}

class CartService {
  CartService._();

  static final ValueNotifier<List<CartItem>> items =
      ValueNotifier<List<CartItem>>(<CartItem>[]);

  static String _keyForCar(AppCar car) =>
      (car.id ?? '${car.brand}-${car.model}').toString();

  static int _indexOf(AppCar car) {
    final key = _keyForCar(car);
    return items.value.indexWhere((e) => _keyForCar(e.car) == key);
  }

  static void addCar(AppCar car, {int quantity = 1}) {
    final safeQty = quantity < 1 ? 1 : quantity;
    final list = List<CartItem>.from(items.value);
    final index = _indexOf(car);
    if (index >= 0) {
      final existing = list[index];
      list[index] = existing.copyWith(quantity: (existing.quantity + safeQty).clamp(1, 99));
    } else {
      list.add(CartItem(car: car, quantity: safeQty));
    }
    items.value = list;
  }

  static void setCarQuantity(AppCar car, int quantity) {
    final safeQty = quantity.clamp(1, 99);
    final list = List<CartItem>.from(items.value);
    final index = _indexOf(car);
    if (index >= 0) {
      list[index] = list[index].copyWith(quantity: safeQty);
    } else {
      list.add(CartItem(car: car, quantity: safeQty));
    }
    items.value = list;
  }

  static void updateQuantity(AppCar car, int change) {
    final list = List<CartItem>.from(items.value);
    final index = _indexOf(car);
    if (index < 0) return;
    final existing = list[index];
    list[index] = existing.copyWith(
      quantity: (existing.quantity + change).clamp(1, 99),
    );
    items.value = list;
  }

  static void removeCar(AppCar car) {
    final list = List<CartItem>.from(items.value)
      ..removeWhere((e) => _keyForCar(e.car) == _keyForCar(car));
    items.value = list;
  }

  static void clear() {
    items.value = <CartItem>[];
  }

  static double get subtotal =>
      items.value.fold(0.0, (sum, e) => sum + (e.car.price * e.quantity));

  static int get totalItems =>
      items.value.fold(0, (sum, e) => sum + e.quantity);
}
