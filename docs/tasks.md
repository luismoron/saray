# Lista de Tareas para la App "Bazar de Saray"

Aquí tienes una lista estructurada de pasos y componentes clave para arrancar y diseñar la app "Bazar de Saray", una aplicación de ventas para repuestos de electrodomésticos y otros productos. Esta lista se basa en las mejores prácticas para una app de e-commerce en Flutter, integrada con Firebase para autenticación, base de datos y otras herramientas. He dividido la lista en fases lógicas para que sea fácil de seguir, priorizando la configuración inicial y el diseño modular.

## 1. Configuración del Proyecto y Dependencias

- [x] **Configurar Firebase en el proyecto Flutter**:
  - [x] Crear un proyecto en Firebase Console (firebase.google.com).
  - [x] Agregar la app Flutter (Android, iOS, Web) al proyecto Firebase y descargar los archivos de configuración (google-services.json para Android, GoogleService-Info.plist para iOS).
  - [x] Instalar dependencias en pubspec.yaml: firebase_core, firebase_auth, cloud_firestore, firebase_storage (para imágenes de productos).
  - [x] Inicializar Firebase en main.dart.
- [x] **Actualizar pubspec.yaml**:
  - [x] Agregar dependencias adicionales: provider (para gestión de estado), http (si necesitas APIs externas), cached_network_image (para imágenes), intl (para formatos de fecha/moneda).
  - [x] Configurar permisos en AndroidManifest.xml e Info.plist para acceso a internet y notificaciones.
- [x] **Configurar el entorno de desarrollo**:
  - [x] Asegurarse de que Flutter esté actualizado (flutter doctor).
  - [x] Configurar emuladores o dispositivos físicos para pruebas.

## 2. Diseño de la Arquitectura y Modelos de Datos

- [x] **Definir modelos de datos**:
  - [x] Usuario: ID, nombre, email, teléfono, dirección, rol (cliente/admin).
  - [x] Producto: ID, nombre, descripción, precio, categoría (ej. "Repuestos de lavadoras"), stock, imágenes (URLs de Firebase Storage).
  - [x] Pedido: ID, usuario, lista de productos, total, estado (pendiente, enviado, entregado), fecha.
  - [x] Categoría: ID, nombre (ej. "Electrodomésticos", "Repuestos").
- [x] **Estructura de carpetas en lib/**:
  - [x] models/: Clases para Usuario, Producto, Pedido, etc.
  - [x] screens/: Pantallas principales (login, home, catálogo, carrito, perfil).
  - [x] widgets/: Componentes reutilizables (botones, tarjetas de productos).
  - [x] services/: Lógica para Firebase (auth_service.dart, firestore_service.dart).
  - [x] providers/: Gestión de estado con Provider (ej. CartProvider para el carrito).
- [x] **Base de datos en Firestore**:
  - [x] Crear colecciones: users, products, orders, categories.
  - [x] Configurar reglas de seguridad (Firestore Rules) para que solo usuarios autenticados puedan leer/escribir datos relevantes.

## 3. Funcionalidades Básicas de la App

- [x] **Autenticación con Firebase Auth**:
  - [x] Pantalla de login/registro con email/contraseña.
  - [x] Recuperación de contraseña (pantalla implementada y probada).
  - [x] Gestión de sesiones (logout automático).
- [x] **Catálogo de Productos**:
  - [x] Pantalla principal con lista de productos (usar ListView o GridView). (Implementado con filtros y búsqueda)
  - [x] Filtros por categoría, búsqueda por nombre.
  - [x] Detalles de producto: imagen, descripción, precio, botón "Agregar al carrito". (Vista básica implementada)
- [x] **Carrito de Compras**:
  - [x] Pantalla para ver productos agregados, calcular total.
  - [x] Funcionalidad para aumentar/disminuir cantidad, eliminar items.
  - [x] Integración con Firestore para guardar carritos por usuario.
- [x] **Proceso de Compra**:
  - [x] Pantalla de checkout: confirmar dirección, método de pago (implementado con pago contra entrega).
  - [x] Crear pedido en Firestore y actualizar stock.
  - [x] Notificaciones push (usar Firebase Cloud Messaging) para confirmaciones.
- [x] **Perfil de Usuario**:
  - [x] Ver/editar datos personales, historial de pedidos.
  - [x] Para admins: panel para agregar/editar productos.
- [x] **Historial de Pedidos Completo**:
  - [x] Pantalla dedicada para ver todos los pedidos del usuario.
  - [x] Filtros por estado de pedido (pendiente, confirmado, enviado, etc.).
  - [x] Búsqueda por ID de pedido.
  - [x] Vista detallada de cada pedido con productos, precios y estado.
  - [x] Navegación desde el perfil de usuario.
  - [x] Solución de problemas de índices de Firestore (procesamiento en cliente).
- [x] **Sistema de Roles de Usuario**:
  - [x] Implementar roles: buyer (comprador), seller_pending, seller (aprobado), admin.
  - [x] Solicitud de vendedor con aprobación admin.
  - [x] Panel admin para gestionar solicitudes.
  - [x] Protección de rutas con RouteGuard para acceso basado en roles.
  - [x] Buyers solo pueden comprar, admins controlan permisos de venta.
- [x] **Panel de Administración**:
  - [x] Pantalla de admin con tabs para productos y usuarios.
  - [x] Gestión completa de productos: agregar, editar, eliminar con imágenes.
  - [x] Gestión completa de usuarios: cambiar roles, bloquear/desbloquear, eliminar usuarios.
  - [x] Integración con Firebase Storage para subir imágenes de productos.
  - [x] Layout optimizado que utiliza todo el espacio disponible.
  - [x] Eliminación de funcionalidades de desarrollo/testing (stock testing, sample products, requests section).
- [x] **Manejo de Errores y Robustez**:
  - [x] Try-catch en construcción de tarjetas de pedido.
  - [x] Try-catch en detalles de pedido con SnackBars informativos.
  - [x] Validaciones de datos nulos en productos y pedidos.
  - [x] Solución de problemas de índices de Firestore.
  - [x] Corregir uso de BuildContext en gaps asíncronos.
  - [x] Reemplazar print con debugPrint para logging seguro.

## 4. Diseño de UI/UX

- [x] **Tema y Estilos**:
  - [x] Usar Material Design para consistencia.
  - [x] Colores: Elegir paleta relacionada con "Bazar de Saray" (tonos naranjas).
  - [ ] Iconos: Usar flutter_icons o material icons.
- [ ] **Navegación**:
  - [x] BottomNavigationBar con tabs: Home, Catálogo, Carrito, Perfil (implementado básico).
  - [x] Usar Navigator para transiciones entre pantallas.
- [ ] **Responsive Design**:
  - [ ] Asegurar que funcione en móviles, tablets y web (usar LayoutBuilder).
  - [ ] Imágenes optimizadas con Firebase Storage.

## 5. Integraciones y Herramientas Adicionales

- [x] **Firebase Storage**: Para subir y servir imágenes de productos.
- [x] **Firebase Cloud Messaging**: Notificaciones para ofertas o actualizaciones de pedidos.
- [ ] **Analytics**: Firebase Analytics para rastrear uso de la app (compras, búsquedas).
- [ ] **Opcionales Avanzados**: Integrar Google Maps para direcciones de entrega, o Stripe para pagos reales.
- [ ] **Pruebas**: Crear tests unitarios (test/) para modelos y servicios. Usar Firebase Emulator Suite para pruebas locales.

## 7. Mejoras y Tareas Adicionales

- [x] **Soporte para Modo Claro y Oscuro**: Implementar temas que respeten la configuración del sistema, con paleta de colores cálida (naranja como seed color) para reflejar el "Bazar de Saray".
- [ ] **Personalización de Tema**: Agregar opción para que el usuario cambie manualmente entre claro/oscuro.
- [x] **Internacionalización (i18n)**: Soporte para múltiples idiomas usando intl. Implementado con archivos ARB para inglés y español, detectando automáticamente el idioma del sistema operativo.
- [ ] **Accesibilidad**: Asegurar que la UI sea accesible (contraste, tamaños de fuente).
- [ ] **Optimización de Rendimiento**: Lazy loading en listas, caching de imágenes.
- [ ] **Sistema de Notificaciones Mejorado**:
  - [x] Implementar notificaciones push con Firebase Cloud Messaging para ofertas y actualizaciones de pedidos.
  - [x] Mejorar el sistema de SnackBars/notificaciones locales:
    - [x] Agregar animaciones personalizadas para las notificaciones.
    - [x] Implementar notificaciones tipo "toast" más elegantes.
    - [x] Agregar sonidos opcionales para notificaciones importantes.
    - [x] Crear un sistema de notificaciones persistentes para mensajes críticos (errores de red, etc.).
    - [x] Implementar notificaciones contextuales que cambien según el estado de la app (modo offline, carrito lleno, etc.).
    - [x] Agregar opción de "no molestar" o silenciar notificaciones por tiempo determinado.
  - [x] Sistema de notificaciones in-app:
    - [x] Centro de notificaciones para ver historial de mensajes.
    - [x] Badges/notificaciones en el ícono de la app para notificaciones no leídas.
    - [ ] Notificaciones de productos relacionados o recomendaciones.
    - [ ] Recordatorios para completar compras abandonadas.

## Pruebas Pendientes

- [x] Probar registro de usuario: Crear cuenta, verificar en Firebase Auth y Firestore.
- [x] Probar login: Iniciar sesión con credenciales válidas.
- [x] Probar logout: Cerrar sesión y verificar que regrese a login.
- [x] Probar reset password: Enviar email de recuperación.
- [x] Verificar navegación: De login a register, y viceversa.
- [x] Probar en emulador/dispositivo Android.
- [x] **Pruebas del Carrito de Compras**:
  - [x] Agregar productos al carrito y verificar persistencia.
  - [x] Modificar cantidades y verificar actualización en tiempo real.
  - [x] Remover productos y verificar actualización.
  - [x] Limpiar carrito completo.
  - [x] Verificar que el carrito persista entre sesiones de usuario.
- [x] **Pruebas del Proceso de Checkout**:
  - [x] Completar formulario de checkout con datos válidos.
  - [x] Verificar creación de pedido en Firestore.
  - [x] Verificar actualización automática del stock.
  - [x] Verificar limpieza del carrito después del pedido.
  - [x] Verificar navegación de vuelta al home después del pedido.
- [x] **Pruebas de Notificaciones**:
  - [x] Verificar notificaciones al agregar productos.
  - [x] Verificar notificaciones al modificar/remover del carrito.
  - [x] Verificar notificaciones de error.
  - [x] Verificar que las notificaciones se oculten automáticamente.
- [x] **Pruebas de Integración**:
  - [x] Flujo completo: Login → Catálogo → Carrito → Checkout → Confirmación.
  - [x] Verificar manejo de errores de red.
  - [x] Verificar comportamiento offline/online.
- [x] **Pruebas del Panel de Administración**:
  - [x] Asignar rol admin a usuario existente.
  - [x] Acceder al panel de administración desde perfil.
  - [x] Ver lista de productos en el panel admin.
  - [x] Agregar nuevo producto con imágenes.
  - [x] Editar producto existente.
  - [x] Eliminar producto con confirmación.
  - [x] Verificar subida de imágenes a Firebase Storage.
  - [x] Verificar actualización en tiempo real del catálogo.
- [x] **Pruebas del Historial de Pedidos**:
  - [x] Acceder al historial desde el perfil de usuario.
  - [x] Ver lista de pedidos existentes.
  - [x] Probar filtros por estado de pedido.
  - [x] Probar búsqueda por ID de pedido.
  - [x] Ver detalles completos de un pedido.
  - [x] Verificar manejo de errores sin índices de Firestore.

## 8. Sistema de Actualizaciones Automáticas (OTA)

- [x] **Implementación del Servicio de Actualizaciones**:
  - [x] Crear `UpdateService` con verificación automática de versiones desde Google Drive.
  - [x] Implementar comparación semántica de versiones (major.minor.patch).
  - [x] Integrar descarga automática de APK desde Google Drive.
  - [x] Implementar instalación automática usando intents de Android.
  - [x] Agregar manejo de permisos para instalación y almacenamiento.
- [x] **UI de Actualizaciones**:
  - [x] Crear `UpdateNotificationBanner` para mostrar actualizaciones disponibles.
  - [x] Implementar `UpdateDialog` con detalles de la nueva versión y notas de cambios.
  - [x] Agregar `UpdateProvider` para gestión de estado de actualizaciones.
  - [x] Integrar verificación automática al iniciar la app.
- [x] **Configuración de Google Drive**:
  - [x] Configurar URLs de descarga directa para APK y version.json.
  - [x] Implementar formato JSON para información de versiones.
  - [x] Configurar permisos públicos para distribución a testers.
- [x] **Script de Deploy Automático**:
  - [x] Crear `deploy.bat` para construcción automática de APK.
  - [x] Implementar copia automática a carpeta de Google Drive.
  - [x] Agregar sincronización automática con Google Drive.
  - [x] Optimizar para distribución a testers sin dispositivos conectados.
- [x] **Documentación Completa**:
  - [x] Crear `UPDATE_SETUP.md` con guía paso a paso.
  - [x] Actualizar `README.md` con información del sistema OTA.
  - [x] Crear `test_updates.bat` para pruebas del sistema.
  - [x] Documentar workflow completo para testers.
- [x] **Mejoras de UI/UX en Productos**:
  - [x] Optimizar layout de tarjetas de productos con texto continuo.
  - [x] Mejorar responsive design de grid de productos.
  - [x] Eliminar sombras innecesarias para mejor rendimiento.
  - [x] Implementar RichText para nombres y descripciones combinadas.
- [x] **Sistema de Dependencias y Compatibilidad**:
  - [x] Resolver problemas de compatibilidad con paquetes Android.
  - [x] Implementar `android_intent_plus` para instalación automática.
  - [x] Agregar manejo robusto de errores en descargas.
  - [x] Optimizar permisos para Android moderno (API 8.0+).

## 9. Mejoras Técnicas y Optimizaciones

- [x] **Corrección de Errores de Linting**:
  - [x] Resolver conflictos de nombres entre widgets.
  - [x] Corregir imports y dependencias faltantes.
  - [x] Optimizar uso de BuildContext en operaciones asíncronas.
- [x] **Actualización de Documentación**:
  - [x] Mantener docs sincronizadas con código implementado.
  - [x] Agregar ejemplos de uso y configuración.
  - [x] Documentar soluciones a problemas comunes.

Esta lista es un punto de partida escalable. Si quieres que implemente alguna parte específica (ej. configurar Firebase o crear una pantalla), dime cuál y procedo. ¿Qué te parece esta estructura? ¿Hay algo que quieras agregar o modificar?
