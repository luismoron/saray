class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role; // 'buyer', 'seller_pending', 'seller', 'admin'

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.role = 'buyer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'buyer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
    };
  }

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      address: data['address'],
      role: data['role'] ?? 'buyer',
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }
}