import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', user.name),
                    _buildInfoRow('Email', user.email),
                    _buildInfoRow('Teléfono', user.phone ?? 'No especificado'),
                    _buildInfoRow('Dirección', user.address ?? 'No especificada'),
                    _buildInfoRow('Rol', _getRoleDisplayName(user.role)),
                    const SizedBox(height: 16),
                    // Los usuarios normales no pueden solicitar ser vendedores
                    // Solo los admins pueden asignar roles desde el panel de administración
                    if (user.role == 'seller_pending') ...[
                      const Text('Solicitud de vendedor enviada, esperando aprobación.'),
                    ] else if (user.role == 'seller') ...[
                      const Text('Eres vendedor aprobado.'),
                      // TODO: Agregar opciones de vendedor
                    ],
                    ElevatedButton(
                      onPressed: () => _showEditProfileDialog(context, user),
                      child: const Text('Editar Perfil'),
                    ),
                    // TODO: Remover después de asignar admin inicial
                    if (user.role != 'admin') ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _assignAdminRole(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Asignar Rol Admin (Temporal)'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Historial de pedidos - Botón para navegar a pantalla dedicada
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.orange),
                title: const Text('Historial de Pedidos'),
                subtitle: const Text('Ver todos tus pedidos anteriores'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).pushNamed('/order-history');
                },
              ),
            ),
            const SizedBox(height: 16),

            // Panel de admin (solo si es admin)
            if (user.role == 'admin') ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel de Administrador',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/admin');
                        },
                        child: const Text('Gestionar Productos'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'buyer':
        return 'Comprador';
      case 'seller':
        return 'Vendedor';
      case 'admin':
        return 'Administrador';
      default:
        return 'Desconocido';
    }
  }

  void _requestSellerStatus(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('seller_requests').add({
        'userId': userId,
        'status': 'pending',
        'requestedAt': Timestamp.now(),
      });

      // Actualizar rol del usuario a 'seller_pending'
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'seller_pending',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud enviada. Esperando aprobación.'), duration: Duration(seconds: 2)),
        );
        // Refrescar pantalla
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address);

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Actualizar usuario en Firestore
              // Por ahora, solo cerrar
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil actualizado (simulado)'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _assignAdminRole(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Rol Admin'),
        content: const Text('¿Estás seguro de que quieres asignarte el rol de administrador? Esta acción es irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await authProvider.assignAdminRole();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Rol admin asignado exitosamente')),
        );
        setState(() {}); // Refrescar la UI
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al asignar rol admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}