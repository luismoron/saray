import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/enhanced_notification_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda: Imagen + Categoría debajo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen del producto
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: product.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            size: 30,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),

                  const SizedBox(height: 6),

                  // Categoría debajo de la imagen
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      product.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Información del producto (expandida)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y precio/stock en columna derecha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre (expandido)
                        Expanded(
                          child: Text(
                            product.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Precio y stock en columna
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Precio
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Stock debajo del precio
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: product.stock > 0
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${l10n.stock}: ${product.stock}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: product.stock > 0
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Descripción
                    Text(
                      product.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Botón de ancho completo
                    if (product.stock > 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCart(context),
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (authProvider.user == null) {
      EnhancedNotificationService().showErrorNotification(
        message: 'Debes iniciar sesión para agregar productos al carrito',
      );
      return;
    }

    try {
      final success = await cartProvider.addToCart(product, quantity: 1);

      if (success) {
        // Mostrar notificación mejorada de producto agregado
        EnhancedNotificationService().showProductAddedToCart(
          productName: product.name,
          onViewCart: () {
            if (context.mounted) {
              Navigator.of(context).pushNamed('/cart');
            }
          },
        );
      } else {
        EnhancedNotificationService().showErrorNotification(
          message:
              'Error al agregar el producto al carrito. Inténtalo de nuevo.',
        );
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      EnhancedNotificationService().showErrorNotification(
        message: 'Error al agregar el producto al carrito. Inténtalo de nuevo.',
      );
    }
  }
}
