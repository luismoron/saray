import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script temporal para asignar rol de admin a un usuario
/// Ejecutar una sola vez y luego eliminar
Future<void> assignAdminRole(String userEmail) async {
  try {
    // Buscar usuario por email
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      debugPrint('Usuario con email $userEmail no encontrado');
      return;
    }

    final userId = userQuery.docs.first.id;

    // Actualizar rol
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': 'admin',
    });

    debugPrint('✅ Rol admin asignado exitosamente a $userEmail');
    debugPrint('ID de usuario: $userId');
  } catch (e) {
    // ignore: avoid_print
    debugPrint('❌ Error al asignar rol admin: $e');
  }
}

// Ejemplo de uso:
// await assignAdminRole('tu-email@ejemplo.com');
