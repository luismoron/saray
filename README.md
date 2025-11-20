# Saray

Una aplicación de e-commerce desarrollada en Flutter para la venta de repuestos de electrodomésticos y otros productos. Construida con Firebase para autenticación, base de datos y servicios de almacenamiento.

## 🚀 Características Implementadas

- **✅ Autenticación de Usuarios**: Login y registro seguro con Firebase Auth.
- **✅ Catálogo de Productos**: Navegar y buscar repuestos y electrodomésticos con filtros.
- **✅ Carrito de Compras**: Agregar productos, gestionar cantidades y proceder al checkout.
- **✅ Gestión de Pedidos**: Realizar pedidos y seguimiento de estado.
- **✅ Sistema de Roles**: Compradores, vendedores y administradores.
- **✅ Panel de Administración**: Gestión completa de productos con subida de imágenes.
- **✅ Temas Claro/Oscuro**: Adaptable a la configuración del sistema.
- **✅ Internacionalización**: Soporte para español e inglés.
- **✅ Actualizaciones Automáticas**: Sistema de actualización OTA desde Google Drive con instalación automática.
- **🔄 Próximas**: Notificaciones push, pruebas exhaustivas del carrito.

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework UI para aplicaciones nativas compiladas.
- **Firebase**:
  - Auth: Autenticación de usuarios.
  - Firestore: Base de datos NoSQL para productos, usuarios y pedidos.
  - Storage: Almacenamiento de imágenes de productos.
  - Cloud Messaging: Notificaciones push (planeado).
- **Provider**: Gestión de estado.
- **Material Design 3**: UI/UX consistente.

## 📱 Plataforma

**Android únicamente** - La app está diseñada exclusivamente para dispositivos Android.

## 🏁 Inicio Rápido

### Prerrequisitos

- Flutter SDK (versión 3.10.0 o superior)
- Dart SDK
- Cuenta Firebase y proyecto configurado

### Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/luismoron/saray.git
   cd saray
   ```

2. Instala dependencias:

   ```bash
   flutter pub get
   ```

3. Configura Firebase:
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   - Agrega la app Android y descarga google-services.json.
   - Coloca el archivo en `android/app/`.

4. Ejecuta la app:

   ```bash
   flutter run
   ```

### Estructura del Proyecto

- `lib/`: Código principal de la aplicación.
  - `models/`: Modelos de datos (User, Product, Order).
  - `screens/`: Pantallas UI (Login, Home, Cart, Admin, etc.).
  - `services/`: Servicios Firebase y lógica de negocio.
  - `widgets/`: Componentes UI reutilizables.
  - `providers/`: Gestión de estado con Provider.
- `docs/`: Documentación del proyecto (tareas, reglas, lógica).
- `test/`: Tests unitarios.

## 📊 Estado del Proyecto (17 de noviembre de 2025)

### ✅ **COMPLETADO (100% Core Ready)**

- ✅ Autenticación completa con Firebase Auth
- ✅ Catálogo de productos con filtros y búsqueda
- ✅ Carrito de compras persistente
- ✅ Sistema de roles (buyer, seller, admin)
- ✅ Panel de administración funcional
- ✅ Temas claro/oscuro
- ✅ Internacionalización (ES/EN)
- ✅ **Sistema de Notificaciones Push** con Firebase Cloud Messaging
- ✅ **Notificaciones Locales Mejoradas** con animaciones
- ✅ **Centro de Notificaciones** in-app
- ✅ **Gestión Completa de Usuarios** (bloqueo, eliminación, roles)

### 📋 **Resumen Completo del Proyecto**

Para información detallada sobre todas las funcionalidades implementadas, arquitectura, métricas y recomendaciones futuras, consulta:

📄 **[Resumen Completo del Proyecto](docs/project_summary.md)**

## ⚡ Sistema de Actualizaciones Automáticas

La app incluye un sistema completo de **actualizaciones over-the-air (OTA)** que permite distribuir nuevas versiones a testers de forma segura y automática.

### Características

- **📱 Instalación Automática**: Un clic para actualizar, el instalador se abre automáticamente
- **🔒 Distribución Segura**: Usa Google Drive en lugar de repositorios públicos
- **📊 Control de Versiones**: Sistema de versiones semántico con notas de cambios
- **🔄 Verificación Automática**: Detecta actualizaciones al iniciar la app
- **👥 Para Testers**: Distribución privada sin exponer código en GitHub

### Cómo Funciona

1. **Nueva Versión**: Desarrollador sube APK y `version.json` a Google Drive
2. **Detección**: App verifica automáticamente si hay actualizaciones
3. **Notificación**: Muestra banner/dialog con información de la nueva versión
4. **Instalación**: Usuario hace clic → descarga automática → instalador se abre
5. **Confirmación**: Usuario confirma instalación (requerido por Android)

### Configuración

Ver [`UPDATE_SETUP.md`](UPDATE_SETUP.md) para instrucciones detalladas de configuración.

### Prueba del Sistema

```bash
# Ejecutar script de prueba
./test_updates.bat
```

**URLs configuradas:**
- APK: `https://drive.google.com/uc?export=download&id=13gJ4dpmFoe8-4ZZ1d_KzYDiV7ZowNaMq`
- Version JSON: `https://drive.google.com/uc?export=download&id=1NEdgg2zDL1Zr3QK6Oeos5iefTKm9eM4D`

### 🔄 **Próximas Prioridades (Fase 2)**

#### 🎨 **Alta Prioridad**

- Responsive Design para tablets y web
- Iconos personalizados
- Accesibilidad mejorada

#### ⚡ **Media Prioridad**

- Lazy Loading en listas grandes
- Firebase Analytics
- Tests unitarios completos

#### 🚀 **Baja Prioridad**

- Google Maps para entregas
- Pagos reales con Stripe
- Notificaciones avanzadas

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor, haz fork del repositorio y envía un pull request.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Contacto

Para preguntas o soporte, contacta al desarrollador.
