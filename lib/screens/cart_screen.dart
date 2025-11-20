import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Solo inicializar si es realmente necesario y no hay items cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Solo inicializar si el usuario está autenticado y el carrito no está inicializado
      if (authProvider.user != null &&
          cartProvider.cartItems.isEmpty &&
          !cartProvider.isLoading) {
        cartProvider.initializeCart(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.hasItems) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _clearCart(context, cartProvider),
                  tooltip: 'Limpiar carrito',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Si no hay items y no está cargando, mostrar vacío inmediatamente
          if (!cartProvider.hasItems && !cartProvider.isLoading) {
            return _buildEmptyCart(context, l10n, theme);
          }

          // Si está cargando y no hay items, mostrar loading
          if (cartProvider.isLoading && !cartProvider.hasItems) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hay items, mostrarlos inmediatamente (incluso si está cargando más datos)
          return Column(
            children: [
              // Lista de items del carrito
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return CartItemCard(
                      cartItem: cartItem,
                      onIncrement: () =>
                          cartProvider.incrementQuantity(cartItem.id),
                      onDecrement: () =>
                          cartProvider.decrementQuantity(cartItem.id),
                      onRemove: () =>
                          _removeCartItem(context, cartProvider, cartItem),
                    );
                  },
                ),
              ),

              // Resumen y checkout
              _buildCartSummary(context, cartProvider, l10n, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos desde el catálogo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/catalog');
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Ir al Catálogo'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartProvider cartProvider,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cartProvider.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón de checkout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _proceedToCheckout(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceder al Pago',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCart(BuildContext context, CartProvider cartProvider) {
    cartProvider.clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Carrito vaciado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeCartItem(
    BuildContext context,
    CartProvider cartProvider,
    cartItem,
  ) {
    cartProvider.removeFromCart(cartItem.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cartItem.product.name} removido del carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartProvider cartProvider) {
    // Navegar al checkout
    Navigator.of(context).pushNamed('/checkout');
  }
}
