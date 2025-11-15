import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  // Constructor desde Firestore
  factory CartItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItem(
      id: id,
      product: Product.fromFirestore(data['product'] as Map<String, dynamic>, data['productId']),
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'product': product.toFirestore(),
      'productId': product.id,
      'quantity': quantity,
      'addedAt': addedAt,
    };
  }

  // Calcular subtotal
  double get subtotal => product.price * quantity;

  // Copiar con cambios
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Verificar si hay stock disponible
  bool get isAvailable => product.stock >= quantity;
}