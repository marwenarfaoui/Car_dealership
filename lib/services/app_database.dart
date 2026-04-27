import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/setup.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/app_car.dart';
import '../models/app_user.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static bool _factoryConfigured = false;
  Database? _db;

  static Future<void> _configureDatabaseFactoryIfNeeded() async {
    if (_factoryConfigured) return;

    if (kIsWeb) {
      await setupSqfliteWebBinaries();
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          break;
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.fuchsia:
          break;
      }
    }

    _factoryConfigured = true;
  }

  Future<Database> get database async {
    await _configureDatabaseFactoryIfNeeded();
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'car_dealership.db'),
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT NOT NULL,
            address TEXT NOT NULL,
            city TEXT NOT NULL,
            zip_code TEXT NOT NULL,
            country TEXT NOT NULL,
            role TEXT NOT NULL,
            password TEXT NOT NULL,
            joined_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE cars (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id TEXT UNIQUE,
            brand TEXT NOT NULL,
            model TEXT NOT NULL,
            year_model TEXT,
            kilometrage INTEGER,
            motorisation TEXT,
            color TEXT,
            consumption_100km REAL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            description TEXT NOT NULL,
            is_featured INTEGER NOT NULL DEFAULT 0,
            image_url TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total REAL NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            car_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY(order_id) REFERENCES orders(id),
            FOREIGN KEY(car_id) REFERENCES cars(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            car_id INTEGER NOT NULL UNIQUE,
            created_at TEXT NOT NULL,
            FOREIGN KEY(car_id) REFERENCES cars(id) ON DELETE CASCADE
          )
        ''');

        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE cars ADD COLUMN remote_id TEXT');
          await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_cars_remote_id ON cars(remote_id)');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              car_id INTEGER NOT NULL UNIQUE,
              created_at TEXT NOT NULL,
              FOREIGN KEY(car_id) REFERENCES cars(id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE cars ADD COLUMN image_url TEXT');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE cars ADD COLUMN year_model TEXT');
          await db.execute('ALTER TABLE cars ADD COLUMN kilometrage INTEGER');
          await db.execute('ALTER TABLE cars ADD COLUMN motorisation TEXT');
          await db.execute('ALTER TABLE cars ADD COLUMN color TEXT');
          await db.execute('ALTER TABLE cars ADD COLUMN consumption_100km REAL');
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'full_name': 'Admin User',
      'email': 'admin@cardealer.com',
      'phone': '12345678',
      'address': 'Head Office',
      'city': 'Tunis',
      'zip_code': '1000',
      'country': 'Tunisia',
      'role': 'admin',
      'password': 'admin123',
      'joined_at': now,
    });

    final cars = <AppCar>[
      const AppCar(
        brand: 'Tesla',
        model: 'Model S Plaid',
        price: 129990,
        stock: 5,
        description: 'High performance electric sedan',
        isFeatured: true,
      ),
      const AppCar(
        brand: 'BMW',
        model: 'M8 Competition',
        price: 136500,
        stock: 3,
        description: 'Luxury sports coupe',
        isFeatured: true,
      ),
      const AppCar(
        brand: 'Porsche',
        model: '911 Turbo',
        price: 184300,
        stock: 4,
        description: 'Iconic sports performance',
      ),
    ];

    for (final car in cars) {
      await db.insert('cars', car.toMap()..remove('id'));
    }
  }

  Future<void> init() async {
    await _configureDatabaseFactoryIfNeeded();
    await database;
  }

  Future<AppUser?> signIn(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.toLowerCase(), password],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<AppUser> createUser(AppUser user, String password) async {
    final db = await database;
    final id = await db.insert('users', user.toMap(password: password)..remove('id'));
    return user.copyWith(id: id);
  }

  Future<void> updateUser(AppUser user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap()..remove('password'),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<AppUser>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'id DESC');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<void> updateUserRole({required int userId, required String role}) async {
    final db = await database;
    await db.update(
      'users',
      {'role': role},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> getAdminCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM users WHERE LOWER(role) = 'admin'",
          ),
        ) ??
        0;
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<List<AppCar>> getCars() async {
    final db = await database;
    final rows = await db.query('cars', orderBy: 'id DESC');
    return rows.map(AppCar.fromMap).toList();
  }

  Future<void> upsertCarsFromBackend(List<Map<String, dynamic>> backendCars) async {
    final db = await database;
    final batch = db.batch();

    for (final car in backendCars) {
      final remoteId = (car['id'] ?? '').toString();
      final brand = (car['brand'] ?? '').toString().trim();
      final model = (car['model'] ?? '').toString().trim();

      if (remoteId.isEmpty || brand.isEmpty || model.isEmpty) {
        continue;
      }

      final priceRaw = car['price'];
      final price = priceRaw is num
          ? priceRaw.toDouble()
          : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;

      final mileageRaw = car['mileage'];
      final mileage = mileageRaw is num
          ? mileageRaw.toInt()
          : int.tryParse(mileageRaw?.toString() ?? '0') ?? 0;

      final yearRaw = car['year'];
      final year = yearRaw is num
          ? yearRaw.toInt()
          : int.tryParse(yearRaw?.toString() ?? '') ?? 0;

      final description = (car['description'] ?? '').toString().trim();
      final computedDescription = [
        if (year > 0) 'Year: $year',
        if (mileage > 0) 'Mileage: $mileage km',
        if (description.isNotEmpty) description,
      ].join(' • ');

      final status = (car['status'] ?? 'available').toString().toLowerCase();
      final inStock = status == 'available' || status == 'reserved';

        final backendMotorisation =
          (car['motorisation'] ?? car['engine'] ?? '').toString().trim();
        final backendColor = (car['color'] ?? '').toString().trim();
        final consumptionRaw = car['consumption_100km'] ?? car['consumption100km'];
        final consumption = consumptionRaw is num
          ? consumptionRaw.toDouble()
          : double.tryParse(consumptionRaw?.toString() ?? '');

      final isFeatured = car['is_featured'] == true ||
          car['is_featured'] == 1 ||
          car['is_featured']?.toString().toLowerCase() == 'true';

      final backendImage =
          (car['image_url'] ?? car['imageUrl'] ?? '').toString().trim();
      final existing = await db.query(
        'cars',
        columns: ['image_url'],
        where: 'remote_id = ?',
        whereArgs: [remoteId],
        limit: 1,
      );
      final existingImage = existing.isNotEmpty
          ? (existing.first['image_url'] as String?)
          : null;
      final imageToStore = backendImage.isNotEmpty ? backendImage : existingImage;

      batch.insert(
        'cars',
        {
          'remote_id': remoteId,
          'brand': brand,
          'model': model,
          'year_model': year > 0 ? year.toString() : null,
          'kilometrage': mileage > 0 ? mileage : null,
          'motorisation': backendMotorisation.isEmpty ? null : backendMotorisation,
          'color': backendColor.isEmpty ? null : backendColor,
          'consumption_100km': consumption,
          'price': price,
          'stock': inStock ? 1 : 0,
          'description': computedDescription.isEmpty ? 'No description' : computedDescription,
          'is_featured': isFeatured ? 1 : 0,
          'image_url': imageToStore,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> addCar(AppCar car) async {
    final db = await database;
    return db.insert('cars', car.toMap()..remove('id'));
  }

  Future<void> updateCar(AppCar car) async {
    final db = await database;
    await db.update('cars', car.toMap()..remove('id'), where: 'id = ?', whereArgs: [car.id]);
  }

  Future<void> deleteCar(int id) async {
    final db = await database;
    await db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  Future<Set<int>> getFavoriteCarIds() async {
    final db = await database;
    final rows = await db.query('favorites', columns: ['car_id']);
    return rows
        .map((row) => row['car_id'])
        .whereType<int>()
        .toSet();
  }

  Future<List<AppCar>> getFavoriteCars() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT c.*
      FROM cars c
      INNER JOIN favorites f ON f.car_id = c.id
      ORDER BY f.created_at DESC
    ''');
    return rows.map(AppCar.fromMap).toList();
  }

  Future<void> toggleFavoriteCar(int carId) async {
    final db = await database;
    final existing = await db.query(
      'favorites',
      columns: ['id'],
      where: 'car_id = ?',
      whereArgs: [carId],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('favorites', {
        'car_id': carId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete('favorites', where: 'car_id = ?', whereArgs: [carId]);
    }
  }
}
