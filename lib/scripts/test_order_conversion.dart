import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

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
      }
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
    print('Testing Order.fromFirestore...');
    final order = Order.fromFirestore(mockOrderData, 'test-order-id');
    print('SUCCESS: Order created successfully');
    print('Order ID: ${order.id}');
    print('Order Status: ${order.status}');
    print('Order Total: ${order.total}');
    print('Order Items Count: ${order.items.length}');
  } catch (e, stackTrace) {
    print('ERROR: Failed to create order: $e');
    print('Stack Trace: $stackTrace');
  }
}