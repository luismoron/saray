import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart' as order_model;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un nuevo pedido
  Future<String?> createOrder(order_model.Order order) async {
    try {
      final docRef = await _firestore
          .collection('orders')
          .add(order.toFirestore());

      // Actualizar stock de productos
      await updateProductStock(order);

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // Obtener pedidos de un usuario
  Stream<List<order_model.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return order_model.Order.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Obtener un pedido específico
  Future<order_model.Order?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return order_model.Order.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order: $e');
      return null;
    }
  }

  // Actualizar estado de un pedido
  Future<bool> updateOrderStatus(
    String orderId,
    order_model.OrderStatus status,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Obtener todos los pedidos (para admins)
  Stream<List<order_model.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return order_model.Order.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Actualizar stock de productos después de crear pedido
  Future<bool> updateProductStock(order_model.Order order) async {
    try {
      final batch = _firestore.batch();

      for (final item in order.items) {
        final productRef = _firestore
            .collection('products')
            .doc(item.product.id);
        batch.update(productRef, {
          'stock': item.product.stock - item.quantity,
          'updatedAt': DateTime.now(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error updating product stock: $e');
      return false;
    }
  }
}
