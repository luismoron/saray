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