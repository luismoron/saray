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
}