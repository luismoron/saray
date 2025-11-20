import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;

void testOrderConversion() async {
  // Simular datos de Firestore como los que se guardarían
  final mockOrderData = {
    'userId': 'test-user-id',
    'items': [
      {
        'product': {
          'id': 'test-product-id',
          'name': 'Test Product',
          'description': 'Test Description',
          'price': 10.0,
          'stock': 100,
          'category': 'test',
          'imageUrl': 'https://example.com/image.jpg',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        'productId': 'test-product-id',
        'quantity': 2,
        'addedAt': Timestamp.now(),
      },
    ],
    'total': 20.0,
    'status': 'pending',
    'deliveryAddress': 'Test Address',
    'phoneNumber': '123456789',
    'notes': 'Test notes',
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  try {
    debugPrint('Testing Order.fromFirestore...');
    final order = order_model.Order.fromFirestore(
      mockOrderData,
      'test-order-id',
    );
    debugPrint('SUCCESS: Order created successfully');
    debugPrint('Order ID: ${order.id}');
    debugPrint('Order Status: ${order.status}');
    debugPrint('Order Total: ${order.total}');
    debugPrint('Order Items Count: ${order.items.length}');
  } catch (e, stackTrace) {
    debugPrint('ERROR: Failed to create order: $e');
    debugPrint('Stack Trace: $stackTrace');
  }
}
