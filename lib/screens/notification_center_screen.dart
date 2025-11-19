import 'package:flutter/material.dart';
import '../services/enhanced_notification_service.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  // Lista de notificaciones simuladas (en una app real vendrían de un servicio)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': '¡Bienvenido a Saray!',
      'message': 'Gracias por registrarte. Explora nuestros productos.',
      'type': 'info',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'read': false,
    },
    {
      'id': '2',
      'title': 'Oferta Especial',
      'message': 'Refrigeradores con 20% de descuento esta semana.',
      'type': 'offer',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'read': false,
    },
    {
      'id': '3',
      'title': 'Pedido Entregado',
      'message': 'Tu pedido #1234 ha sido entregado exitosamente.',
      'type': 'success',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _markAllAsRead,
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(theme)
          : _buildNotificationsList(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _testNotifications,
        tooltip: 'Probar Notificaciones',
        child: const Icon(Icons.notification_add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las nuevas notificaciones aparecerán aquí',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification, theme);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, ThemeData theme) {
    final isRead = notification['read'] as bool;
    final type = notification['type'] as String;

    Color backgroundColor;
    IconData icon;

    switch (type) {
      case 'success':
        backgroundColor = Colors.green.shade50;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red.shade50;
        icon = Icons.error;
        break;
      case 'warning':
        backgroundColor = Colors.orange.shade50;
        icon = Icons.warning;
        break;
      case 'offer':
        backgroundColor = Colors.purple.shade50;
        icon = Icons.local_offer;
        break;
      default:
        backgroundColor = Colors.blue.shade50;
        icon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? theme.cardColor : backgroundColor,
      child: InkWell(
        onTap: () => _markAsRead(notification['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: _getIconColor(type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isRead
                                  ? theme.colorScheme.onSurface
                                  : _getIconColor(type),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getIconColor(type),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification['timestamp'] as DateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Color _getIconColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'offer':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Ahora';
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });

    EnhancedNotificationService().showSuccessNotification(
      message: 'Todas las notificaciones marcadas como leídas',
    );
  }

  void _testNotifications() {
    // Mostrar diferentes tipos de notificaciones para probar
    Future.delayed(const Duration(milliseconds: 500), () {
      EnhancedNotificationService().showSuccessNotification(
        message: '¡Notificación de éxito! Esta notificación se oculta automáticamente en 2 segundos.',
      );
    });

    Future.delayed(const Duration(seconds: 3), () {
      EnhancedNotificationService().showErrorNotification(
        message: 'Notificación de error de prueba. Se oculta en 2 segundos.',
      );
    });

    Future.delayed(const Duration(seconds: 6), () {
      EnhancedNotificationService().showInfoNotification(
        message: 'Notificación informativa. Ahora ocupa más ancho disponible.',
      );
    });

    Future.delayed(const Duration(seconds: 9), () {
      EnhancedNotificationService().showWarningNotification(
        message: 'Advertencia de prueba. Verifica que ocupe más ancho.',
      );
    });
  }
}