import 'package:flutter/material.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void initialize(BuildContext context) {
    // Este método debe llamarse en el MaterialApp para obtener el contexto
  }

  GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  // Notificación de éxito con animación
  void showSuccessNotification({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 2), // Cambiado a 2 segundos
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showEnhancedSnackBar(
      message: message,
      title: title,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  // Notificación de error con animación
  void showErrorNotification({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 2), // Cambiado a 2 segundos
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showEnhancedSnackBar(
      message: message,
      title: title,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  // Notificación de advertencia
  void showWarningNotification({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 2), // Cambiado a 2 segundos
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showEnhancedSnackBar(
      message: message,
      title: title,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  // Notificación informativa
  void showInfoNotification({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 2), // Cambiado a 2 segundos
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showEnhancedSnackBar(
      message: message,
      title: title,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  // Notificación de pedido confirmado
  void showOrderConfirmation({
    required String orderId,
    required double total,
    VoidCallback? onViewOrder,
  }) {
    _showEnhancedSnackBar(
      title: '¡Pedido Confirmado! 🎉',
      message: 'Pedido #$orderId por \$${total.toStringAsFixed(2)}',
      backgroundColor: Colors.green.shade700,
      icon: Icons.shopping_cart,
      duration: const Duration(
        seconds: 3,
      ), // Más tiempo para confirmaciones importantes
      onAction: onViewOrder,
      actionLabel: 'Ver Pedido',
    );
  }

  // Notificación de producto agregado al carrito
  void showProductAddedToCart({
    required String productName,
    VoidCallback? onViewCart,
  }) {
    _showEnhancedSnackBar(
      title: 'Producto Agregado 🛒',
      message: '$productName añadido al carrito',
      backgroundColor: Colors.blue.shade600,
      icon: Icons.add_shopping_cart,
      duration: const Duration(seconds: 2),
      onAction: onViewCart,
      actionLabel: 'Ver Carrito',
    );
  }

  // Notificación de oferta especial
  void showSpecialOffer({
    required String productName,
    required int discount,
    VoidCallback? onViewOffer,
  }) {
    _showEnhancedSnackBar(
      title: '¡Oferta Especial! 🏷️',
      message: '$productName con $discount% de descuento',
      backgroundColor: Colors.purple.shade600,
      icon: Icons.local_offer,
      duration: const Duration(seconds: 3),
      onAction: onViewOffer,
      actionLabel: 'Ver Oferta',
    );
  }

  // Método privado para mostrar SnackBar mejorado
  void _showEnhancedSnackBar({
    required String message,
    String? title,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final snackBar = SnackBar(
      content: EnhancedSnackBarContent(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior:
          SnackBarBehavior.floating, // Usar floating para poder usar margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 16,
      ), // Margen inferior agregado
      padding: EdgeInsets.zero, // Sin padding extra
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  // Limpiar todas las notificaciones
  void clearAllNotifications() {
    _scaffoldMessengerKey.currentState?.clearSnackBars();
  }

  // Ocultar notificación actual
  void hideCurrentNotification() {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }
}

// Widget personalizado para el contenido del SnackBar
class EnhancedSnackBarContent extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EnhancedSnackBarContent({
    super.key,
    this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Forzar ancho completo
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // Reducido para más espacio
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24, // Mantenido consistente
          ),
          const SizedBox(width: 10), // Reducido ligeramente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Reducido ligeramente
                    ),
                  ),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Reducido ligeramente
                  ),
                  maxLines: 3, // Aumentado de 2 a 3
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.white,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget para mostrar notificaciones tipo Toast (más elegante)
class ToastNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;

  const ToastNotification({
    super.key,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 3),
  });

  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ToastNotification(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0, // Cambiado a 0 para ocupar todo el ancho
      right: 0, // Cambiado a 0 para ocupar todo el ancho
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
              ), // Margen pequeño para no tocar los bordes
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    // Asegurar que tome todo el espacio disponible
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3, // Aumentado de 2 a 3 para más texto
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
