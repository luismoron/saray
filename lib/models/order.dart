import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    try {
      debugPrint('DEBUG Order.fromFirestore: Processing order $id');
      debugPrint('DEBUG Order.fromFirestore: Data keys: ${data.keys.toList()}');

      final items =
          (data['items'] as List<dynamic>?)
              ?.map((item) {
                try {
                  return CartItem.fromFirestore(
                    item as Map<String, dynamic>,
                    '',
                  );
                } catch (e) {
                  debugPrint(
                    'ERROR Order.fromFirestore: Failed to parse cart item: $e',
                  );
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<CartItem>()
              .toList() ??
          [];

      final statusString = data['status'] as String?;
      debugPrint('DEBUG Order.fromFirestore: Status string: $statusString');

      final status = OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == statusString,
        orElse: () => OrderStatus.pending,
      );

      final createdAt =
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final updatedAt =
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      return Order(
        id: id,
        userId: data['userId'] ?? '',
        items: items,
        total: _parseDouble(data['total']),
        status: status,
        deliveryAddress: data['deliveryAddress'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        notes: data['notes'],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      debugPrint('ERROR Order.fromFirestore: Failed to create order $id: $e');
      debugPrint('ERROR Order.fromFirestore: Stack trace: $stackTrace');
      rethrow;
    }
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

  // Función auxiliar para parsear double de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('ERROR: Failed to parse double from string: $value');
        return 0.0;
      }
    }
    debugPrint('ERROR: Unexpected type for total: ${value.runtimeType}');
    return 0.0;
  }
}
