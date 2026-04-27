class AppUser {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String zipCode;
  final String country;
  final String role;
  final DateTime joinedAt;

  const AppUser({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.country,
    this.role = 'client',
    required this.joinedAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  AppUser copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? country,
    String? role,
    DateTime? joinedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toMap({String? password}) {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'country': country,
      'role': role,
      'password': password,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      zipCode: map['zip_code'] as String,
      country: map['country'] as String,
      role: (map['role'] as String?) ?? 'client',
      joinedAt: DateTime.parse(map['joined_at'] as String),
    );
  }
}
