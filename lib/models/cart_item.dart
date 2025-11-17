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
    try {
      print('DEBUG CartItem.fromFirestore: Processing cart item');
      print('DEBUG CartItem.fromFirestore: Data keys: ${data.keys.toList()}');

      final productData = data['product'] as Map<String, dynamic>?;
      if (productData == null) {
        throw Exception('Product data is null');
      }

      final productId = data['productId'] as String? ?? '';
      final product = Product.fromFirestore(productData, productId);

      return CartItem(
        id: id,
        product: product,
        quantity: _parseInt(data['quantity']),
        addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('ERROR CartItem.fromFirestore: Failed to create cart item: $e');
      print('ERROR CartItem.fromFirestore: Stack trace: $stackTrace');
      rethrow;
    }
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

  // Función auxiliar para parsear int de manera segura
  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('ERROR: Failed to parse int from string: $value');
        return 1;
      }
    }
    print('ERROR: Unexpected type for quantity: ${value.runtimeType}');
    return 1;
  }
}