import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;
  double get total => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  bool get hasItems => _cartItems.isNotEmpty;

  // Inicializar carrito para un usuario
  void initializeCart(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      loadCart();
    }
  }

  // Cargar carrito del usuario
  Future<void> loadCart() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _cartService.getUserCart(_currentUserId!).listen((cartItems) {
        _cartItems = cartItems;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading cart: $e');
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

    final result = await _cartService.addToCart(_currentUserId!, cartItem);
    return result != null;
  }

  // Actualizar cantidad de un item
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (_currentUserId == null) return false;

    final success = await _cartService.updateCartItemQuantity(_currentUserId!, cartItemId, quantity);
    if (success) {
      // Actualizar localmente para feedback inmediato
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        if (quantity <= 0) {
          _cartItems.removeAt(index);
        } else {
          _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        }
        notifyListeners();
      }
    }
    return success;
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

    final success = await _cartService.removeFromCart(_currentUserId!, cartItemId);
    if (success) {
      _cartItems.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    }
    return success;
  }

  // Limpiar carrito
  Future<bool> clearCart() async {
    if (_currentUserId == null) return false;

    final success = await _cartService.clearCart(_currentUserId!);
    if (success) {
      _cartItems.clear();
      notifyListeners();
    }
    return success;
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
    _cartItems.clear();
    _currentUserId = null;
    notifyListeners();
  }
}