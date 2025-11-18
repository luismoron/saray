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
                    if (user.role == 'buyer') ...[
                      ElevatedButton(
                        onPressed: () => _requestSellerStatus(context, user.id),
                        child: const Text('Solicitar ser Vendedor'),
                      ),
                    ] else if (user.role == 'seller_pending') ...[
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/stock-test');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('🧪 Probar Sistema de Stock'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Solicitudes de Vendedores Pendientes:'),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('seller_requests')
                            .where('status', isEqualTo: 'pending')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final requests = snapshot.data?.docs ?? [];

                          if (requests.isEmpty) {
                            return const Text('No hay solicitudes pendientes.');
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              final request = requests[index];
                              final requestData = request.data() as Map<String, dynamic>;
                              final userId = requestData['userId'] as String;

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return const ListTile(title: Text('Cargando...'));
                                  }

                                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                                    return const ListTile(title: Text('Error al cargar usuario'));
                                  }

                                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  final userName = userData['name'] ?? 'Desconocido';

                                  return ListTile(
                                    title: Text('Solicitud de: $userName'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () => _approveSellerRequest(context, request.id, userId),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => _rejectSellerRequest(context, request.id, userId),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
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
      case 'seller_pending':
        return 'Vendedor (Pendiente)';
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
          const SnackBar(content: Text('Solicitud enviada. Esperando aprobación.'), duration: Duration(seconds: 3)),
        );
        // Refrescar pantalla
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: Duration(seconds: 3)),
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
                const SnackBar(content: Text('Perfil actualizado (simulado)'), duration: Duration(seconds: 3)),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _approveSellerRequest(BuildContext context, String requestId, String userId) async {
    try {
      // Actualizar solicitud a approved
      await FirebaseFirestore.instance.collection('seller_requests').doc(requestId).update({
        'status': 'approved',
      });

      // Actualizar rol del usuario a 'seller'
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'seller',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud aprobada.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _rejectSellerRequest(BuildContext context, String requestId, String userId) async {
    try {
      // Actualizar solicitud a rejected
      await FirebaseFirestore.instance.collection('seller_requests').doc(requestId).update({
        'status': 'rejected',
      });

      // Revertir rol del usuario a 'buyer'
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'buyer',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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