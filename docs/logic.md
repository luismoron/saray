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

- **Implementación del Panel de Administración**:
  - Creada AdminScreen con tabs para "Productos" y "Solicitudes".
  - Gestión completa de productos: lista de productos con opciones de editar/eliminar.
  - Formulario para agregar/editar productos con subida de imágenes múltiples.
  - Integración con ImagePicker para seleccionar imágenes de la galería.
  - Validaciones de formulario y manejo de errores.
  - Navegación desde ProfileScreen para usuarios admin.
  - Actualización automática de la lista de productos tras cambios.

### Fecha: 17 de noviembre de 2025 (Historial de Pedidos Completo)

- **Implementación del Historial de Pedidos Completo**:
  - Creada OrderHistoryScreen como pantalla dedicada con funcionalidades avanzadas.
  - Implementada navegación desde ProfileScreen con botón dedicado en lugar del historial integrado.
  - Agregada funcionalidad de búsqueda por ID de pedido con TextField y filtrado en tiempo real.
  - Implementados filtros por estado de pedido (todos, pendiente, confirmado, preparando, enviado, entregado, cancelado).
  - Creada vista detallada de pedidos usando DraggableScrollableSheet con scroll interno.
  - Mostradas imágenes de productos, cantidades, precios individuales y totales.
  - Integración completa con Firebase Firestore para consultas en tiempo real con filtros.
  - Estados visuales con colores e iconos apropiados para cada estado de pedido.
  - Manejo de errores y estados de carga apropiados.
  - Limpieza del código: removidos métodos no usados (_showOrderDetails) e imports innecesarios del ProfileScreen.
  - Actualización de rutas en main.dart para incluir '/order-history'.

- **Mejoras en la Arquitectura**:
  - Separación clara entre vista resumida (ProfileScreen) y vista detallada (OrderHistoryScreen).
  - Mejor organización del código con responsabilidades bien definidas.
  - UI/UX mejorada con navegación intuitiva y filtros funcionales.

### Fecha: 18 de noviembre de 2025 (Solución de Índices Firestore)

- **Problema de Índices de Firestore Resuelto**:
  - Identificado error "The query requires an index" en consultas compuestas (userId + createdAt + status).
  - Solución implementada: Simplificar consultas Firestore eliminando orderBy del servidor.
  - Nuevo enfoque: Filtrar solo por userId en Firestore, ordenar y filtrar adicionalmente en cliente.
  - Ventajas: Elimina dependencia de índices compuestos, funciona inmediatamente, mejor rendimiento para pocos pedidos.
  - Desventajas: Menos eficiente para miles de pedidos (no aplicable en desarrollo actual).

- **Mejoras de Manejo de Errores**:
  - Agregado try-catch en construcción de tarjetas de pedido con fallback a tarjeta de error.
  - Agregado try-catch en vista detallada de pedidos con SnackBars informativos.
  - Validaciones de nombres de productos nulos para evitar crashes.
  - Logging detallado de errores para debugging futuro.

- **Optimización de Consultas**:
  - Eliminadas consultas complejas que requerían índices compuestos.
  - Procesamiento híbrido: servidor para filtrado básico, cliente para ordenamiento y filtros avanzados.
  - Mejor UX: filtros funcionan sin delays de creación de índices.

- **Pruebas del Panel de Administración Realizadas**:
  - Asignación exitosa de rol admin mediante botón temporal en perfil.
  - Acceso al panel de administración desde perfil de usuario admin.
  - Visualización correcta de lista de productos con imágenes y precios.
  - Funcionamiento del formulario de agregar producto: validaciones, subida de imágenes.
  - Edición de productos existentes con actualización en tiempo real.
  - Eliminación de productos con confirmación de usuario.
  - Integración completa con Firebase Storage para gestión de imágenes.
  - Navegación fluida entre tabs de productos y solicitudes.

- **Corrección de Errores de Compilación**:
  - Agregado import faltante de cloud_firestore en AuthProvider.
  - Implementado método copyWith en modelo User para actualizaciones.
  - Verificación exitosa de compilación sin errores fatales.

- **Estado Actual de la Aplicación**:
  - ✅ Autenticación completa y funcional.
  - ✅ Catálogo de productos con filtros y búsqueda.
  - ✅ Carrito de compras persistente.
  - ✅ Sistema de roles con panel de administración probado.
  - ✅ Gestión completa de productos por administradores.
  - ✅ Historial de pedidos completo con pantalla dedicada.
  - 🔄 Pendiente: Pruebas exhaustivas de carrito y checkout.
  - 🔄 Pendiente: Implementación de notificaciones push.
