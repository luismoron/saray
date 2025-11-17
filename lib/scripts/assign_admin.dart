import 'package:cloud_firestore/cloud_firestore.dart';

/// Script temporal para asignar rol de admin a un usuario
/// Ejecutar una sola vez y luego eliminar
Future<void> assignAdminRole(String userEmail) async {
  try {
    // Buscar usuario por email
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();

    if (userQuery.docs.isEmpty) {
      print('Usuario con email $userEmail no encontrado');
      return;
    }

    final userDoc = userQuery.docs.first;
    final userId = userDoc.id;

    // Actualizar rol a admin
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'role': 'admin'});

    print('✅ Rol admin asignado exitosamente a $userEmail');
    print('ID de usuario: $userId');

  } catch (e) {
    print('❌ Error al asignar rol admin: $e');
  }
}

// Ejemplo de uso:
// await assignAdminRole('tu-email@ejemplo.com');