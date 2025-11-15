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
  - [ ] Configurar permisos en AndroidManifest.xml e Info.plist para acceso a internet y notificaciones.
- [ ] **Configurar el entorno de desarrollo**:
  - [ ] Asegurarse de que Flutter esté actualizado (flutter doctor).
  - [ ] Configurar emuladores o dispositivos físicos para pruebas.

## 2. Diseño de la Arquitectura y Modelos de Datos
- [x] **Definir modelos de datos**:
  - [x] Usuario: ID, nombre, email, teléfono, dirección, rol (cliente/admin).
  - [ ] Producto: ID, nombre, descripción, precio, categoría (ej. "Repuestos de lavadoras"), stock, imágenes (URLs de Firebase Storage).
  - [ ] Pedido: ID, usuario, lista de productos, total, estado (pendiente, enviado, entregado), fecha.
  - [ ] Categoría: ID, nombre (ej. "Electrodomésticos", "Repuestos").
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
  - [ ] Detalles de producto: imagen, descripción, precio, botón "Agregar al carrito".
- [ ] **Carrito de Compras**:
  - [ ] Pantalla para ver productos agregados, calcular total.
  - [ ] Funcionalidad para aumentar/disminuir cantidad, eliminar items.
  - [ ] Integración con Firestore para guardar carritos por usuario.
- [ ] **Proceso de Compra**:
  - [ ] Pantalla de checkout: confirmar dirección, método de pago (integrar con Stripe o PayPal si es necesario, pero empezar simple).
  - [ ] Crear pedido en Firestore y actualizar stock.
  - [ ] Notificaciones push (usar Firebase Cloud Messaging) para confirmaciones.
- [ ] **Perfil de Usuario**:
  - [ ] Ver/editar datos personales, historial de pedidos.
  - [ ] Para admins: panel para agregar/editar productos.

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
- [ ] **Firebase Storage**: Para subir y servir imágenes de productos.
- [ ] **Firebase Cloud Messaging**: Notificaciones para ofertas o actualizaciones de pedidos.
- [ ] **Analytics**: Firebase Analytics para rastrear uso de la app (compras, búsquedas).
- [ ] **Opcionales Avanzados**: Integrar Google Maps para direcciones de entrega, o Stripe para pagos reales.
- [ ] **Pruebas**: Crear tests unitarios (test/) para modelos y servicios. Usar Firebase Emulator Suite para pruebas locales.

## 7. Mejoras y Tareas Adicionales
- [x] **Soporte para Modo Claro y Oscuro**: Implementar temas que respeten la configuración del sistema, con paleta de colores cálida (naranja como seed color) para reflejar el "Bazar de Saray".
- [ ] **Personalización de Tema**: Agregar opción para que el usuario cambie manualmente entre claro/oscuro.
- [x] **Internacionalización (i18n)**: Soporte para múltiples idiomas usando intl. Implementado con archivos ARB para inglés y español, detectando automáticamente el idioma del sistema operativo.
- [ ] **Accesibilidad**: Asegurar que la UI sea accesible (contraste, tamaños de fuente).
- [ ] **Optimización de Rendimiento**: Lazy loading en listas, caching de imágenes.

## Pruebas Pendientes
- [x] Probar registro de usuario: Crear cuenta, verificar en Firebase Auth y Firestore.
- [x] Probar login: Iniciar sesión con credenciales válidas.
- [x] Probar logout: Cerrar sesión y verificar que regrese a login.
- [x] Probar reset password: Enviar email de recuperación.
- [x] Verificar navegación: De login a register, y viceversa.
- [x] Probar en emulador/dispositivo Android.

Esta lista es un punto de partida escalable. Si quieres que implemente alguna parte específica (ej. configurar Firebase o crear una pantalla), dime cuál y procedo. ¿Qué te parece esta estructura? ¿Hay algo que quieras agregar o modificar?