import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.phoneNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructor desde Firestore
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromFirestore(item as Map<String, dynamic>, ''))
          .toList() ?? [],
      total: (data['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'total': total,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copiar con cambios
  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? total,
    OrderStatus? status,
    String? deliveryAddress,
    String? phoneNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}