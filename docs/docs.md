# Documentación del Proyecto "Bazar de Saray"

Aquí se documentará el progreso general del proyecto, incluyendo implementaciones, decisiones de diseño y cualquier detalle relevante a medida que avancemos en el desarrollo de la app.

## Resumen del Proyecto

"Bazar de Saray" es una aplicación de e-commerce desarrollada en Flutter para la venta de repuestos de electrodomésticos y otros productos. Está diseñada exclusivamente para Android, integrada con Firebase para autenticación, base de datos y almacenamiento.

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

## Arquitectura de la App

- **Modelos**: User, Product, Order, Category, CartItem.
- **Providers**: AuthProvider, ProductProvider, CartProvider.
- **Services**: AuthService, StorageService.
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
- Permisos configurados para Android e iOS.

## Avances Recientes (18 de noviembre de 2025)

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
- **Mejoras de estabilidad**:
  - Manejo de errores en construcción de UI.
  - Validaciones de datos nulos.
  - Logging detallado para debugging.

## Estado de Pruebas (18 de noviembre de 2025)

- ✅ **Autenticación**: Registro, login, logout probados exitosamente.
- ✅ **Panel de Administración**: Asignación de rol admin, gestión de productos con imágenes.
- ✅ **Historial de Pedidos**: Navegación, filtros, búsqueda y detalles probados.
- ✅ **Compilación**: App compila sin errores en Android.
- ✅ **Manejo de Errores**: Try-catch implementado en componentes críticos.
- 🔄 **Carrito y Checkout**: Pendiente pruebas exhaustivas finales.
- 🔄 **Notificaciones**: Pendiente implementación.

## Roadmap de Mejoras Futuras

### 🟢 FASE 2 - Optimización de Rendimiento

- Lazy loading en listas largas para mejor rendimiento
- Caching inteligente de imágenes de productos
- Firebase Analytics para métricas de uso y compras

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
