import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/sample_data_service.dart';
import '../services/order_service.dart';
import '../models/order.dart' as order_model;

class StockTestScreen extends StatefulWidget {
  const StockTestScreen({super.key});

  @override
  State<StockTestScreen> createState() => _StockTestScreenState();
}

class _StockTestScreenState extends State<StockTestScreen> {
  bool _isLoading = false;
  String _testResults = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Stock'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pruebas del Sistema de Stock',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta pantalla permite probar que el stock NO se reduce al agregar productos al carrito, pero SÍ se reduce al confirmar la compra.',
            ),
            const SizedBox(height: 24),

            // Botones de prueba
            _buildTestButton(
              '1. Agregar Productos de Ejemplo',
              'Agrega productos de prueba a Firestore',
              _addSampleProducts,
            ),
            const SizedBox(height: 12),

            _buildTestButton(
              '2. Verificar Stock Inicial',
              'Muestra el stock actual de los productos',
              _checkInitialStock,
            ),
            const SizedBox(height: 12),

            _buildTestButton(
              '3. Agregar al Carrito (sin reducir stock)',
              'Agrega productos al carrito y verifica que el stock no cambia',
              _testAddToCart,
            ),
            const SizedBox(height: 12),

            _buildTestButton(
              '4. Simular Checkout (con reducción de stock)',
              'Simula una compra y verifica que el stock se reduce',
              _testCheckout,
            ),
            const SizedBox(height: 12),

            _buildTestButton(
              '5. Limpiar Carrito',
              'Limpia el carrito para nuevas pruebas',
              _clearCart,
            ),
            const SizedBox(height: 24),

            // Resultados
            if (_testResults.isNotEmpty) ...[
              Text(
                'Resultados de las Pruebas:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _testResults,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, String description, VoidCallback onPressed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : onPressed,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ejecutar Prueba'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSampleProducts() async {
    setState(() => _isLoading = true);
    try {
      final sampleService = SampleDataService();
      await sampleService.addSampleProducts();

      // Recargar productos
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts();

      _addResult('✅ Productos de ejemplo agregados exitosamente');
    } catch (e) {
      _addResult('❌ Error agregando productos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkInitialStock() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final products = productProvider.products;

    if (products.isEmpty) {
      _addResult('❌ No hay productos disponibles. Ejecuta primero "Agregar Productos de Ejemplo"');
      return;
    }

    _addResult('📊 Stock Inicial de Productos:');
    for (final product in products) {
      _addResult('  • ${product.name}: ${product.stock} unidades');
    }
  }

  Future<void> _testAddToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (authProvider.user == null) {
      _addResult('❌ Debes iniciar sesión para esta prueba');
      return;
    }

    final products = productProvider.products;
    if (products.isEmpty) {
      _addResult('❌ No hay productos disponibles');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Guardar stock inicial
      final initialStocks = Map<String, int>.fromEntries(
        products.map((p) => MapEntry(p.id, p.stock))
      );

      _addResult('🛒 Agregando productos al carrito...');

      // Agregar algunos productos al carrito
      for (int i = 0; i < products.length && i < 3; i++) {
        final product = products[i];
        final success = await cartProvider.addToCart(product, quantity: 1);
        if (success) {
          _addResult('  ✅ ${product.name} agregado al carrito');
        } else {
          _addResult('  ❌ Error agregando ${product.name}');
        }
      }

      // Esperar un momento para que se actualice
      await Future.delayed(const Duration(seconds: 2));

      // Verificar que el stock no cambió
      await productProvider.loadProducts();
      final currentProducts = productProvider.products;

      _addResult('🔍 Verificando que el stock NO cambió:');
      bool stockUnchanged = true;

      for (final product in currentProducts) {
        final initialStock = initialStocks[product.id] ?? 0;
        if (product.stock != initialStock) {
          _addResult('  ❌ ERROR: ${product.name} cambió de $initialStock a ${product.stock}');
          stockUnchanged = false;
        } else {
          _addResult('  ✅ ${product.name}: stock sigue siendo ${product.stock}');
        }
      }

      if (stockUnchanged) {
        _addResult('🎉 ÉXITO: El stock NO se redujo al agregar al carrito');
      } else {
        _addResult('💥 ERROR: El stock se redujo incorrectamente');
      }

    } catch (e) {
      _addResult('❌ Error en la prueba: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCheckout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (authProvider.user == null) {
      _addResult('❌ Debes iniciar sesión para esta prueba');
      return;
    }

    if (!cartProvider.hasItems) {
      _addResult('❌ No hay productos en el carrito. Ejecuta primero "Agregar al Carrito"');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Guardar stock antes del checkout
      final preCheckoutStocks = Map<String, int>.fromEntries(
        productProvider.products.map((p) => MapEntry(p.id, p.stock))
      );

      _addResult('💳 Simulando checkout...');

      // Crear un pedido simulado
      final order = order_model.Order(
        id: '',
        userId: authProvider.user!.id,
        items: cartProvider.cartItems,
        total: cartProvider.total,
        status: order_model.OrderStatus.pending,
        deliveryAddress: 'Dirección de prueba',
        phoneNumber: '+1234567890',
        notes: 'Pedido de prueba para verificar reducción de stock',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderService = OrderService();
      final orderId = await orderService.createOrder(order);

      if (orderId != null) {
        _addResult('✅ Pedido creado exitosamente: $orderId');

        // Limpiar carrito
        await cartProvider.clearCart();

        // Recargar productos para ver el stock actualizado
        await productProvider.loadProducts();

        // Verificar que el stock se redujo
        _addResult('🔍 Verificando que el stock SÍ se redujo:');
        bool stockReduced = false;

        for (final cartItem in order.items) {
          final product = productProvider.products.firstWhere(
            (p) => p.id == cartItem.product.id,
            orElse: () => cartItem.product,
          );

          final preStock = preCheckoutStocks[cartItem.product.id] ?? 0;
          final expectedStock = preStock - cartItem.quantity;

          if (product.stock == expectedStock) {
            _addResult('  ✅ ${product.name}: $preStock → ${product.stock} (reducido ${cartItem.quantity})');
            stockReduced = true;
          } else {
            _addResult('  ❌ ERROR: ${product.name} esperado $expectedStock, actual ${product.stock}');
          }
        }

        if (stockReduced) {
          _addResult('🎉 ÉXITO: El stock se redujo correctamente en el checkout');
        } else {
          _addResult('💥 ERROR: El stock no se redujo en el checkout');
        }

      } else {
        _addResult('❌ Error creando el pedido');
      }

    } catch (e) {
      _addResult('❌ Error en la prueba de checkout: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      final success = await cartProvider.clearCart();
      if (success) {
        _addResult('✅ Carrito limpiado exitosamente');
      } else {
        _addResult('❌ Error limpiando el carrito');
      }
    } catch (e) {
      _addResult('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults += (_testResults.isEmpty ? '' : '\n') + result;
    });
  }
}