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

- **Próximos Pasos**:
  - Crear proyecto en Firebase Console y descargar archivos de configuración.
  - Configurar permisos en AndroidManifest.xml e Info.plist.
  - Crear modelos de datos (User, Product, Order).
  - Implementar autenticación con Firebase Auth.