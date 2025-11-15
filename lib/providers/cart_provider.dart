import 'package:flutter/material.dart';
import 'dart:async';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _currentUserId;
  StreamSubscription<List<CartItem>>? _cartSubscription;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;
  double get total => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  bool get hasItems => _cartItems.isNotEmpty;

  // Inicializar carrito para un usuario
  void initializeCart(String userId) {
    if (_currentUserId == userId && _cartSubscription != null) {
      // Ya está inicializado para este usuario
      return;
    }

    // Cancelar suscripción anterior si existe
    _cartSubscription?.cancel();

    _currentUserId = userId;
    loadCart();
  }

  // Cargar carrito del usuario
  Future<void> loadCart() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _cartSubscription = _cartService.getUserCart(_currentUserId!).listen(
        (cartItems) {
          _cartItems = cartItems;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          print('Error loading cart: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error setting up cart stream: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar producto al carrito
  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_currentUserId == null) return false;

    final cartItem = CartItem(
      id: '', // Se asignará en Firestore
      product: product,
      quantity: quantity,
      addedAt: DateTime.now(),
    );

    // Actualizar localmente para feedback inmediato
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      // Si ya existe, incrementar cantidad localmente
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity
      );
    } else {
      // Si no existe, agregar nuevo item con ID temporal
      _cartItems.insert(0, cartItem.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}'));
    }
    notifyListeners();

    // Luego sincronizar con Firestore
    try {
      final result = await _cartService.addToCart(_currentUserId!, cartItem);
      if (result != null) {
        // Actualizar el ID real si se agregó correctamente
        if (existingIndex != -1) {
          // Ya se actualizó la cantidad, no necesitamos hacer nada más
        } else {
          // Reemplazar el item temporal con el real
          final tempIndex = _cartItems.indexWhere((item) => item.id.startsWith('temp_'));
          if (tempIndex != -1) {
            _cartItems[tempIndex] = _cartItems[tempIndex].copyWith(id: result);
          }
        }
        notifyListeners();
        return true;
      } else {
        // Revertir cambios locales si falló
        if (existingIndex != -1) {
          _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
            quantity: _cartItems[existingIndex].quantity - quantity
          );
        } else {
          _cartItems.removeWhere((item) => item.id.startsWith('temp_'));
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      // Revertir cambios locales si falló
      if (existingIndex != -1) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity - quantity
        );
      } else {
        _cartItems.removeWhere((item) => item.id.startsWith('temp_'));
      }
      notifyListeners();
      return false;
    }
  }

  // Actualizar cantidad de un item
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (_currentUserId == null) return false;

    // Actualizar localmente para feedback inmediato
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return false;

    final oldQuantity = _cartItems[index].quantity;
    if (quantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
    }
    notifyListeners();

    // Sincronizar con Firestore
    try {
      final success = await _cartService.updateCartItemQuantity(_currentUserId!, cartItemId, quantity);
      if (!success) {
        // Revertir cambios locales si falló
        if (quantity <= 0) {
          // Reinsertar el item si fue removido
          final removedItem = _cartItems.firstWhere(
            (item) => item.id == cartItemId,
            orElse: () => _cartItems[index].copyWith(quantity: oldQuantity),
          );
          if (removedItem.id != cartItemId) {
            _cartItems.insert(index, removedItem.copyWith(quantity: oldQuantity));
          }
        } else {
          _cartItems[index] = _cartItems[index].copyWith(quantity: oldQuantity);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating cart item: $e');
      // Revertir cambios locales si falló
      if (quantity <= 0) {
        final removedItem = _cartItems.firstWhere(
          (item) => item.id == cartItemId,
          orElse: () => _cartItems[index].copyWith(quantity: oldQuantity),
        );
        if (removedItem.id != cartItemId) {
          _cartItems.insert(index, removedItem.copyWith(quantity: oldQuantity));
        }
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: oldQuantity);
      }
      notifyListeners();
      return false;
    }
  }

  // Incrementar cantidad
  Future<bool> incrementQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    return await updateQuantity(cartItemId, item.quantity + 1);
  }

  // Decrementar cantidad
  Future<bool> decrementQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    return await updateQuantity(cartItemId, item.quantity - 1);
  }

  // Remover item del carrito
  Future<bool> removeFromCart(String cartItemId) async {
    if (_currentUserId == null) return false;

    // Actualizar localmente para feedback inmediato
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return false;

    final removedItem = _cartItems[index];
    _cartItems.removeAt(index);
    notifyListeners();

    // Sincronizar con Firestore
    try {
      final success = await _cartService.removeFromCart(_currentUserId!, cartItemId);
      if (!success) {
        // Revertir cambios locales si falló
        _cartItems.insert(index, removedItem);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error removing from cart: $e');
      // Revertir cambios locales si falló
      _cartItems.insert(index, removedItem);
      notifyListeners();
      return false;
    }
  }

  // Limpiar carrito
  Future<bool> clearCart() async {
    if (_currentUserId == null) return false;

    // Actualizar localmente para feedback inmediato
    final clearedItems = List<CartItem>.from(_cartItems);
    _cartItems.clear();
    notifyListeners();

    // Sincronizar con Firestore
    try {
      final success = await _cartService.clearCart(_currentUserId!);
      if (!success) {
        // Revertir cambios locales si falló
        _cartItems.addAll(clearedItems);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error clearing cart: $e');
      // Revertir cambios locales si falló
      _cartItems.addAll(clearedItems);
      notifyListeners();
      return false;
    }
  }

  // Verificar si un producto está en el carrito
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  // Obtener cantidad de un producto en el carrito
  int getProductQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(id: '', product: Product(id: '', name: '', description: '', price: 0, category: '', stock: 0, imageUrls: [], createdAt: DateTime.now(), updatedAt: DateTime.now()), quantity: 0, addedAt: DateTime.now()),
    );
    return item.quantity;
  }

  // Limpiar estado cuando el usuario cambia
  void clearState() {
    _cartSubscription?.cancel();
    _cartSubscription = null;
    _cartItems.clear();
    _currentUserId = null;
    notifyListeners();
  }
}