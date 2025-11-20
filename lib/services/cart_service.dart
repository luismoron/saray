import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener el carrito de un usuario
  Stream<List<CartItem>> getUserCart(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CartItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Agregar producto al carrito
  Future<String?> addToCart(String userId, CartItem cartItem) async {
    try {
      // Verificar si el producto ya está en el carrito
      final existingItem = await _getCartItemByProductId(
        userId,
        cartItem.product.id,
      );

      if (existingItem != null) {
        // Si existe, actualizar cantidad
        final newQuantity = existingItem.quantity + cartItem.quantity;
        await updateCartItemQuantity(userId, existingItem.id, newQuantity);
        return existingItem.id;
      } else {
        // Si no existe, agregar nuevo
        final docRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add(cartItem.toFirestore());
        return docRef.id;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return null;
    }
  }

  // Actualizar cantidad de un item del carrito
  Future<bool> updateCartItemQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        // Si cantidad es 0 o menor, eliminar el item
        return await removeFromCart(userId, cartItemId);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .update({'quantity': quantity});
      return true;
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      return false;
    }
  }

  // Remover producto del carrito
  Future<bool> removeFromCart(String userId, String cartItemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  // Limpiar todo el carrito
  Future<bool> clearCart(String userId) async {
    try {
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final batch = _firestore.batch();
      for (final doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }

  // Obtener item del carrito por productId
  Future<CartItem?> _getCartItemByProductId(
    String userId,
    String productId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return CartItem.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cart item: $e');
      return null;
    }
  }

  // Calcular total del carrito
  Future<double> getCartTotal(String userId) async {
    try {
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      double total = 0;
      for (final doc in cartItems.docs) {
        final cartItem = CartItem.fromFirestore(doc.data(), doc.id);
        total += cartItem.subtotal;
      }
      return total;
    } catch (e) {
      debugPrint('Error calculating cart total: $e');
      return 0;
    }
  }
}
