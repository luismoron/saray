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
- Sistema de Roles: Compradores por defecto, solicitud de vendedor con aprobación admin.
- Panel de Administración: Gestión completa de productos (agregar, editar, eliminar con imágenes), aprobación de solicitudes de vendedor.
- **Sistema de Roles**: Compradores por defecto, solicitud para ser vendedor con aprobación admin.
- Permisos configurados para Android e iOS.

## Avances Recientes (17 de noviembre de 2025)
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

## Estado de Pruebas (17 de noviembre de 2025)
- ✅ **Autenticación**: Registro, login, logout probados exitosamente.
- ✅ **Panel de Administración**: Asignación de rol admin, gestión de productos con imágenes.
- ✅ **Compilación**: App compila sin errores en Android.
- 🔄 **Carrito y Checkout**: Pendiente pruebas exhaustivas.
- 🔄 **Notificaciones**: Pendiente implementación.

## Próximos Pasos
- Realizar pruebas exhaustivas del carrito de compras y proceso de checkout.
- Implementar notificaciones push con Firebase Cloud Messaging.
- Mejorar UI/UX: agregar iconos, optimizar responsive design.
- Optimizar rendimiento: lazy loading, caching de imágenes.
- Implementar sistema de reseñas y calificaciones de productos.
- Agregar funcionalidad de búsqueda avanzada y filtros adicionales.

Para más detalles, consulta `logic.md` para lógica implementada, `rules.md` para reglas del proyecto, y `tasks.md` para la lista completa de tareas.