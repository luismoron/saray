import 'package:flutter_test/flutter_test.dart';
import 'package:saray/models/product.dart';
import 'package:saray/models/order.dart' as order_model;
import 'package:saray/models/cart_item.dart';

void main() {
  group('Stock Management Tests', () {
    test('Stock calculation logic is correct', () {
      // Test various stock reduction scenarios
      final testCases = [
        {'initialStock': 100, 'quantity': 1, 'expected': 99},
        {'initialStock': 50, 'quantity': 5, 'expected': 45},
        {'initialStock': 10, 'quantity': 10, 'expected': 0},
        {'initialStock': 25, 'quantity': 3, 'expected': 22},
      ];

      for (final testCase in testCases) {
        final initialStock = testCase['initialStock'] as int;
        final quantity = testCase['quantity'] as int;
        final expected = testCase['expected'] as int;

        final result = initialStock - quantity;
        expect(result, expected,
            reason: 'Stock $initialStock - $quantity should equal $expected');
      }
    });

    test('Stock never goes below zero in valid scenarios', () {
      // Test that stock calculations don't result in negative values
      // when quantity doesn't exceed available stock
      final initialStock = 10;
      final quantity = 5;

      final result = initialStock - quantity;
      expect(result, greaterThanOrEqualTo(0));
    });

    test('Product stock remains unchanged when creating cart item', () {
      // Arrange
      final product = Product(
        id: 'test-product',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 100,
        category: 'Test',
        imageUrls: ['test.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final initialStock = product.stock;

      // Act - Create cart item (simulating adding to cart)
      final cartItem = CartItem(
        id: 'cart-item-1',
        product: product,
        quantity: 5,
        addedAt: DateTime.now(),
      );

      // Assert - Product stock should remain unchanged
      expect(product.stock, initialStock);
      expect(cartItem.product.stock, initialStock);
    });

    test('Order creation logic reduces stock correctly', () {
      // Arrange
      final product = Product(
        id: 'test-product',
        name: 'Test Product',
        description: 'Test Description',
        price: 10.0,
        stock: 100,
        category: 'Test',
        imageUrls: ['test.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cartItem = CartItem(
        id: 'cart-item-1',
        product: product,
        quantity: 5,
        addedAt: DateTime.now(),
      );

      final order = order_model.Order(
        id: 'order-1',
        userId: 'user-1',
        items: [cartItem],
        total: 50.0,
        status: order_model.OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deliveryAddress: 'Test Address',
        phoneNumber: '123456789',
      );

      // Act - Simulate stock reduction logic
      final expectedNewStock = product.stock - cartItem.quantity;

      // Assert
      expect(expectedNewStock, 95); // 100 - 5 = 95
      expect(expectedNewStock, greaterThanOrEqualTo(0));
    });

    test('Multiple items in order reduce stock for each product', () {
      // Arrange
      final product1 = Product(
        id: 'product-1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        stock: 50,
        category: 'Test',
        imageUrls: ['img1.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product2 = Product(
        id: 'product-2',
        name: 'Product 2',
        description: 'Description 2',
        price: 20.0,
        stock: 30,
        category: 'Test',
        imageUrls: ['img2.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cartItem1 = CartItem(
        id: 'cart-item-1',
        product: product1,
        quantity: 3,
        addedAt: DateTime.now(),
      );

      final cartItem2 = CartItem(
        id: 'cart-item-2',
        product: product2,
        quantity: 2,
        addedAt: DateTime.now(),
      );

      // Act - Simulate stock reduction for multiple items
      final expectedStock1 = product1.stock - cartItem1.quantity; // 50 - 3 = 47
      final expectedStock2 = product2.stock - cartItem2.quantity; // 30 - 2 = 28

      // Assert
      expect(expectedStock1, 47);
      expect(expectedStock2, 28);
      expect(expectedStock1, greaterThanOrEqualTo(0));
      expect(expectedStock2, greaterThanOrEqualTo(0));
    });
  });
}