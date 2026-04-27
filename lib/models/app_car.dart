class AppCar {
  final int? id;
  final String brand;
  final String model;
  final String? yearModel;
  final int? kilometrage;
  final String? motorisation;
  final String? color;
  final double? consumptionPer100km;
  final double price;
  final int stock;
  final String description;
  final bool isFeatured;
  final String? imageUrl;

  const AppCar({
    this.id,
    required this.brand,
    required this.model,
    this.yearModel,
    this.kilometrage,
    this.motorisation,
    this.color,
    this.consumptionPer100km,
    required this.price,
    required this.stock,
    required this.description,
    this.isFeatured = false,
    this.imageUrl,
  });

  AppCar copyWith({
    int? id,
    String? brand,
    String? model,
    String? yearModel,
    int? kilometrage,
    String? motorisation,
    String? color,
    double? consumptionPer100km,
    double? price,
    int? stock,
    String? description,
    bool? isFeatured,
    String? imageUrl,
  }) {
    return AppCar(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      yearModel: yearModel ?? this.yearModel,
      kilometrage: kilometrage ?? this.kilometrage,
      motorisation: motorisation ?? this.motorisation,
      color: color ?? this.color,
      consumptionPer100km: consumptionPer100km ?? this.consumptionPer100km,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      isFeatured: isFeatured ?? this.isFeatured,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year_model': yearModel,
      'kilometrage': kilometrage,
      'motorisation': motorisation,
      'color': color,
      'consumption_100km': consumptionPer100km,
      'price': price,
      'stock': stock,
      'description': description,
      'is_featured': isFeatured ? 1 : 0,
      'image_url': imageUrl,
    };
  }

  factory AppCar.fromMap(Map<String, dynamic> map) {
    return AppCar(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      yearModel: map['year_model'] as String?,
      kilometrage: map['kilometrage'] as int?,
      motorisation: map['motorisation'] as String?,
      color: map['color'] as String?,
      consumptionPer100km: (map['consumption_100km'] as num?)?.toDouble(),
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      description: map['description'] as String,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      imageUrl: map['image_url'] as String?,
    );
  }
}
