import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/order.dart' as order_model;
import '../services/order_service.dart';
import '../services/enhanced_notification_service.dart';
import '../services/notification_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del pedido
                    _buildOrderSummary(context, cartProvider, theme),

                    const SizedBox(height: 24),

                    // Información de entrega
                    _buildDeliveryInfo(context, theme, authProvider),

                    const SizedBox(height: 24),

                    // Método de pago (placeholder)
                    _buildPaymentMethod(context, theme),

                    const SizedBox(height: 24),

                    // Notas adicionales
                    _buildNotes(context, theme),

                    const SizedBox(height: 32),

                    // Botón de confirmar pedido
                    _buildConfirmButton(context, cartProvider, theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de productos
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} x${item.quantity}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cartProvider.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, ThemeData theme, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Entrega',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Dirección
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección de entrega',
                hintText: 'Calle, número, ciudad, código postal',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una dirección';
                }
                return null;
              },
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono de contacto',
                hintText: '+1234567890',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un teléfono';
                }
                return null;
              },
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de Pago',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Placeholder para método de pago
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pago contra entrega',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Paga cuando recibas tu pedido',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notas Adicionales (Opcional)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Instrucciones especiales',
                hintText: 'Ej: Tocar timbre, dejar en portería, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, CartProvider cartProvider, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: cartProvider.hasItems ? () => _confirmOrder(context, cartProvider) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Confirmar Pedido',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      EnhancedNotificationService().showErrorNotification(
        message: 'Debes iniciar sesión para realizar un pedido',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Crear el pedido
      final order = order_model.Order(
        id: '', // Se asignará en Firestore
        userId: authProvider.user!.id,
        items: cartProvider.cartItems,
        total: cartProvider.total,
        status: order_model.OrderStatus.pending,
        deliveryAddress: _addressController.text,
        phoneNumber: _phoneController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderService = OrderService();
      final orderId = await orderService.createOrder(order);

      if (orderId != null) {
        // Limpiar el carrito
        await cartProvider.clearCart();

        // Mostrar confirmación mejorada y navegar
        if (context.mounted) {
          EnhancedNotificationService().showOrderConfirmation(
            orderId: orderId,
            total: cartProvider.total,
            onViewOrder: () {
              // TODO: Navegar a detalles del pedido cuando se implemente
              Navigator.of(context).pushNamed('/order-history');
            },
          );

          // Enviar notificación push
          await NotificationService().showOrderConfirmationNotification(orderId, cartProvider.total);

          // Navegar de vuelta al home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (context.mounted) {
          EnhancedNotificationService().showErrorNotification(
            message: 'Error al crear el pedido. Inténtalo de nuevo.',
          );
        }
      }
    } catch (e) {
      print('Error creating order: $e');
      if (context.mounted) {
        EnhancedNotificationService().showErrorNotification(
          message: 'Error al procesar el pedido. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}