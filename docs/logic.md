# Lógica del Proyecto "Bazar de Saray"

Aquí se documentará toda la lógica implementada, decisiones tomadas y pasos realizados en el desarrollo de la app. Por ahora, está vacío. Actualiza este archivo con cada avance significativo.

## Avances Realizados

### Fecha: 14 de noviembre de 2025

- **Configuración Inicial de Firebase**:
  - Agregadas dependencias de Firebase al pubspec.yaml: firebase_core, firebase_auth, cloud_firestore, firebase_storage.
  - Agregadas dependencias adicionales: provider, http, cached_network_image, intl.
  - Inicializado Firebase en main.dart con WidgetsFlutterBinding.ensureInitialized() y Firebase.initializeApp().
  - Cambiado el tema de la app a colores naranjas para reflejar el "bazar".
  - Simplificada la pantalla principal con un mensaje de bienvenida.

- **Implementación de Autenticación Básica**:
  - Creado modelo User en lib/models/user.dart.
  - Creado AuthService en lib/services/auth_service.dart con métodos para registro, login, logout, reset password y obtener datos de usuario.
  - Creado AuthProvider en lib/providers/auth_provider.dart para gestión de estado de autenticación con Provider.
  - Creadas pantallas: LoginScreen, RegisterScreen, HomeScreen en lib/screens/.
  - Actualizado main.dart para usar MultiProvider, rutas nombradas y AuthWrapper para navegación condicional basada en autenticación.
  - La app ahora muestra Login si no autenticado, o Home si sí.

- **Próximos Pasos**:
  - Probar la autenticación creando una cuenta de prueba.
  - Crear modelos para Product y Order.
  - Implementar catálogo de productos con Firestore.
  - Agregar carrito de compras y checkout.

### Fecha: 17 de noviembre de 2025

- **Completación de Modelos de Datos**:
  - Modelo Product ya estaba implementado con campos completos (ID, nombre, descripción, precio, categoría, stock, imageUrls, timestamps).
  - Creado modelo Category en lib/models/category.dart con ID, nombre, descripción, timestamps. Incluye métodos fromFirestore, toFirestore, copyWith.

- **Configuración de Permisos**:
  - Android: Agregados permisos en AndroidManifest.xml para internet, network state, wake lock, C2DM receive (para Firebase y notificaciones).
  - iOS: Agregados UIBackgroundModes en Info.plist para fetch y remote-notification (para FCM).

- **Verificación del Entorno de Desarrollo**:
  - Ejecutado flutter doctor: Todo configurado correctamente (Flutter 3.38.1, Android SDK 36.1.0, dispositivos conectados, red ok).

- **Integración de Firebase Storage**:
  - Creado StorageService en lib/services/storage_service.dart con métodos para subir imágenes de productos (una o múltiples), eliminar imágenes y obtener referencias de storage.

- **Tema Personalizado Claro/Oscuro**:
  - Creado AppTheme en lib/themes/app_theme.dart con paleta de colores específica (blanco suave, azul suave, azul primario, azul navy).
  - Integrado en main.dart, reemplazando el tema por defecto. Respeta configuración del sistema.

- **Actualización de Documentación**:
  - Actualizado tasks.md con todas las tareas completadas marcadas como [x].
  - Actualizado docs.md con resumen completo del proyecto, tecnologías, arquitectura y avances.
  - Actualizado logic.md con detalles de implementaciones recientes.

- **Sistema de Roles Actualizado**:
  - Cambiado modelo User: roles ahora 'buyer' (comprador), 'seller_pending' (solicitud enviada), 'seller' (aprobado), 'admin'.
  - Por defecto, nuevos usuarios son 'buyer'.
  - En ProfileScreen: botón para solicitar ser vendedor, lógica para mostrar estado de solicitud.
  - Panel admin: lista de solicitudes pendientes con botones para aprobar/rechazar.
  - Colección Firestore 'seller_requests' para manejar solicitudes.

### Fecha: 17 de noviembre de 2025 (Actualización)

- **Implementación Completa del Perfil de Usuario con Sistema de Roles**:
  - ProfileScreen completamente funcional: muestra datos personales, historial de pedidos, opciones de edición.
  - Lógica de roles implementada: usuarios buyer pueden solicitar ser seller, admins pueden aprobar/rechazar.
  - Panel admin integrado en ProfileScreen para usuarios con rol 'admin'.
  - Manejo de estados: buyer, seller_pending, seller, admin con UI apropiada para cada uno.
  - Integración con Firestore para actualizar roles y manejar solicitudes de vendedor.
  - Validaciones y manejo de errores en solicitudes y aprobaciones.