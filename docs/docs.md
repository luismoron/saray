# Documentación del Proyecto "Saray"

Aquí se documentará el progreso general del proyecto, incluyendo implementaciones, decisiones de diseño y cualquier detalle relevante a medida que avancemos en el desarrollo de la app.

## Resumen del Proyecto

"Saray" es una aplicación de e-commerce desarrollada en Flutter para la venta de repuestos de electrodomésticos y otros productos. Está diseñada exclusivamente para Android, integrada con Firebase para autenticación, base de datos y almacenamiento.

## Tecnologías Utilizadas

- **Flutter**: Framework para desarrollo móvil.
- **Firebase**:
  - Firebase Auth: Autenticación de usuarios.
  - Cloud Firestore: Base de datos NoSQL.
  - Firebase Storage: Almacenamiento de imágenes.
  - Firebase App Check: Seguridad.
- **Provider**: Gestión de estado.
- **Material Design 3**: UI/UX consistente.
- **Internacionalización**: Soporte para español e inglés.
- **Sistema OTA**: Actualizaciones automáticas desde Google Drive.

## Arquitectura de la App

- **Modelos**: User, Product, Order, Category, CartItem, UpdateInfo.
- **Providers**: AuthProvider, ProductProvider, CartProvider, UpdateProvider.
- **Services**: AuthService, StorageService, UpdateService.
- **Screens**: Login, Register, Home, Catalog, Cart, Checkout, ResetPassword.
- **Widgets**: Reutilizables para UI.
- **Temas**: Claro y oscuro personalizados con paleta de colores azul-navy.

## Funcionalidades Implementadas

- Autenticación completa (registro, login, reset password).
- Catálogo de productos con filtros y búsqueda.
- Carrito de compras persistente.
- Proceso de checkout con pago contra entrega.
- Temas claro/oscuro.
- Internacionalización.
- Almacenamiento de imágenes en Firebase Storage.
- Perfil de Usuario: Ver/editar datos personales, historial de pedidos, panel para admins.
- **Sistema de Roles Reforzado**: Buyers solo pueden comprar, admins controlan permisos de venta. Protección de rutas con RouteGuard.
- **Panel de Administración Expandido**: Nueva tab "Usuarios" para gestión completa de roles por parte de admins.
- **Sistema de Roles**: Compradores por defecto, solicitud para ser vendedor con aprobación admin.
- **Sistema de Actualizaciones Automáticas (OTA)**: Verificación automática desde Google Drive, instalación automática con intents de Android, UI nativa con banner y diálogo.
- Permisos configurados para Android e iOS.

## Avances Recientes (20 de noviembre de 2025)

- Completado modelo Category.
- Configurados permisos en AndroidManifest.xml e Info.plist.
- Verificado entorno de desarrollo con flutter doctor.
- Implementado StorageService para subir imágenes de productos.
- Integrado tema personalizado claro/oscuro con colores específicos.
- Actualizado sistema de roles: compradores por defecto, solicitud de vendedor con aprobación admin.
- **Implementado y probado Panel de Administración completo**:
  - Gestión CRUD de productos con subida de imágenes.
  - Sistema de roles funcional con asignación temporal de admin.
  - Interfaz de administración con tabs para productos y solicitudes.
  - Validaciones y manejo de errores en formularios.
- **Historial de Pedidos completamente funcional**:
  - Pantalla dedicada con filtros por estado y búsqueda por ID.
  - Vista detallada de pedidos con productos e imágenes.
  - Solución de problemas de índices de Firestore mediante procesamiento en cliente.
  - Manejo robusto de errores con try-catch y validaciones.
- **Sistema de Actualizaciones Automáticas (OTA) completamente integrado**:
  - Verificación automática de actualizaciones al iniciar la app.
  - Banner de notificación integrado en pantalla principal.
  - **Botón de descarga contextual** en AppBar (solo visible cuando hay actualización disponible).
  - Diálogo detallado con notas de versión.
  - **Lectura de version.json desde assets** del APK.
  - **Descarga manual del APK** (usuario decide cuándo instalar).
  - Servicio UpdateService con verificación desde Google Drive.
  - UpdateProvider para gestión de estado.
  - Script deploy.bat optimizado para distribución a testers.
  - Documentación completa en UPDATE_SETUP.md.
- **Cambio de nombre del proyecto**: De "Bazar de Saray" a simplemente "Saray" en toda la aplicación y documentación.
- **Mejoras de UI/UX en productos**:
  - Optimización de tarjetas de productos con layout continuo.
  - Eliminación de sombras innecesarias.
  - RichText para mejor presentación de nombres y descripciones.
  - **Tarjetas del carrito optimizadas** con el mismo estilo compacto que el catálogo.
- **Mejoras de estabilidad**:
  - Manejo de errores en construcción de UI.
  - Validaciones de datos nulos.
  - Logging detallado para debugging.
  - Resolución de conflictos de dependencias Android.

## Estado de Pruebas (20 de noviembre de 2025)

- ✅ **Autenticación**: Registro, login, logout probados exitosamente.
- ✅ **Panel de Administración**: Asignación de rol admin, gestión de productos con imágenes.
- ✅ **Historial de Pedidos**: Navegación, filtros, búsqueda y detalles probados.
- ✅ **Sistema OTA**: Verificación automática al iniciar app, banner de notificaciones, botón contextual de descarga, descarga manual del APK probadas.
- ✅ **Script Deploy**: `deploy.bat` probado y funcionando correctamente.
- ✅ **Cambio de Nombre**: Nombre del proyecto actualizado a "Saray" en toda la aplicación.
- ✅ **Compilación**: App compila sin errores en Android.
- ✅ **Manejo de Errores**: Try-catch implementado en componentes críticos.
- ✅ **Carrito y Checkout**: Tarjetas compactas como catálogo implementadas, pendientes pruebas exhaustivas finales.
- 🔄 **Notificaciones**: Pendiente implementación.

## Roadmap de Mejoras Futuras

### 🟢 FASE 1.5 - Mejoras del Sistema OTA

- Dashboard de versiones para admins con control de releases
- Notificaciones push para actualizaciones disponibles
- Estadísticas de adopción de versiones por usuarios
- Rollback automático en caso de versiones problemáticas
- Compresión de APKs para descargas más rápidas

### 🟢 FASE 2 - Optimización de Rendimiento

- Lazy loading en listas largas para mejor rendimiento
- Caching inteligente de imágenes de productos
- Firebase Analytics para métricas de uso y compras
- **Mejoras al Sistema OTA**: Notificaciones push para nuevas versiones, changelog automático, rollback de versiones

### 🟢 FASE 3 - Funcionalidades Avanzadas

- Sistema de reseñas y calificaciones de productos
- Búsqueda avanzada con filtros adicionales (precio, ubicación, etc.)
- Google Maps para selección visual de direcciones de entrega
- Integración de pagos reales con Stripe

### 🟢 FASE 4 - Sistema de Notificaciones Mejorado

- Animaciones personalizadas para notificaciones
- Notificaciones tipo toast más elegantes
- Centro de notificaciones in-app con historial
- Notificaciones contextuales según estado de la app

Para más detalles, consulta `logic.md` para lógica implementada, `rules.md` para reglas del proyecto, y `tasks.md` para la lista completa de tareas.
