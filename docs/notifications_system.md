# Documentación: Sistema de Notificaciones de Saray

## 📱 Resumen

La app "Saray" cuenta con un sistema completo de notificaciones que incluye notificaciones push mediante Firebase Cloud Messaging (FCM) y un sistema mejorado de notificaciones locales con animaciones y funcionalidades avanzadas.

## 🏗️ Arquitectura del Sistema

### Servicios Implementados

#### 1. `NotificationService` (`lib/services/notification_service.dart`)
Servicio principal para manejar notificaciones push con FCM.

**Características:**
- Configuración automática de FCM al iniciar la app
- Manejo de mensajes en foreground, background y app terminada
- Suscripción a tópicos para notificaciones masivas
- Notificaciones locales como respaldo
- Métodos específicos para diferentes tipos de notificaciones

**Métodos principales:**
```dart
- initialize(): Configuración inicial del servicio
- showOrderConfirmationNotification(): Notificación de pedido confirmado
- showOfferNotification(): Notificación de ofertas especiales
- showOutOfStockNotification(): Notificación de producto agotado
- subscribeToTopic(): Suscripción a tópicos
- unsubscribeFromTopic(): Desuscripción de tópicos
```

#### 2. `EnhancedNotificationService` (`lib/services/enhanced_notification_service.dart`)
Servicio avanzado para notificaciones locales con UI mejorada.

**Características:**
- SnackBars animados con iconos y colores temáticos
- Notificaciones tipo Toast con animaciones de entrada/salida
- Sistema de scaffoldMessengerKey para gestión global
- Notificaciones contextuales según el estado de la app

**Tipos de notificaciones:**
```dart
- showSuccessNotification(): Verde, para confirmaciones
- showErrorNotification(): Rojo, para errores
- showWarningNotification(): Naranja, para advertencias
- showInfoNotification(): Azul, para información
- showOrderConfirmation(): Confirmación de pedido con acción
- showProductAddedToCart(): Producto agregado con acción al carrito
- showSpecialOffer(): Ofertas especiales
```

#### 3. `ToastNotification` (Widget)
Widget personalizado para notificaciones flotantes tipo Toast.

**Características:**
- Animaciones de deslizamiento y fade
- Posicionamiento automático en la parte superior
- Auto-desaparición después de duración especificada
- Compatible con Overlay para mostrar sobre cualquier pantalla

### Configuración de Firebase

#### Android (build.gradle.kts)
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

#### Dependencias (pubspec.yaml)
```yaml
firebase_messaging: ^15.0.0
flutter_local_notifications: ^17.0.0
```

## 🎯 Funcionalidades Implementadas

### 1. Notificaciones Push
- ✅ Confirmación de pedidos
- ✅ Ofertas y promociones
- ✅ Actualizaciones de estado de pedidos
- ✅ Productos agotados
- ✅ Suscripción a tópicos por categorías

### 2. Notificaciones Locales Mejoradas
- ✅ SnackBars con animaciones y iconos
- ✅ Notificaciones Toast flotantes
- ✅ Centro de notificaciones in-app
- ✅ Notificaciones contextuales
- ✅ Acciones interactivas (botones en notificaciones)

### 3. Centro de Notificaciones
Ubicado en: `lib/screens/notification_center_screen.dart`

**Características:**
- Lista de notificaciones con estado leído/no leído
- Marcado individual y masivo como leído
- Iconos y colores por tipo de notificación
- Timestamps relativos ("hace 2 horas")
- Notificaciones simuladas para demostración

## 🔧 Integración en la App

### Inicialización
En `lib/main.dart`:
```dart
void main() async {
  // ... configuración Firebase existente
  await NotificationService().initialize();
}
```

### Uso en Pantallas

#### Checkout Screen
```dart
// Notificación mejorada de pedido confirmado
EnhancedNotificationService().showOrderConfirmation(
  orderId: orderId,
  total: cartProvider.total,
  onViewOrder: () => Navigator.of(context).pushNamed('/order-history'),
);

// Notificación push
await NotificationService().showOrderConfirmationNotification(orderId, cartProvider.total);
```

#### Product Card
```dart
// Notificación de producto agregado
EnhancedNotificationService().showProductAddedToCart(
  productName: product.name,
  onViewCart: () => Navigator.of(context).pushNamed('/cart'),
);
```

## 🎨 Diseño y UX

### Paleta de Colores
- **Éxito**: Verde (#4CAF50) - Confirmaciones, pedidos completados
- **Error**: Rojo (#F44336) - Errores, problemas
- **Advertencia**: Naranja (#FF9800) - Alertas, stock bajo
- **Información**: Azul (#2196F3) - Información general
- **Ofertas**: Púrpura (#9C27B0) - Promociones especiales

### Animaciones
- **SnackBars**: Slide desde abajo con fade
- **Toast**: Slide desde arriba con fade y bounce
- **Iconos**: Escalado sutil al aparecer
- **Duraciones**: 2-5 segundos según importancia

## 📋 Estados de Notificación

### Estados Implementados
- **Pendiente**: No leído, destacado visualmente
- **Leído**: Opacidad reducida, sin indicador
- **Acción requerida**: Con botones interactivos

### Gestión de Estados
- Marcado automático al tocar
- Opción de marcar todas como leídas
- Persistencia de estado (simulada en demo)

## 🔮 Funcionalidades Futuras

### Pendientes por Implementar
- [ ] Notificaciones de productos relacionados
- [ ] Recordatorios de compras abandonadas
- [ ] Sonidos personalizables
- [ ] Notificaciones programadas
- [ ] Badges en íconos de app
- [ ] Notificaciones push desde servidor

### Mejoras Sugeridas
- Integración con Firebase Analytics para métricas
- Personalización de preferencias de usuario
- Notificaciones geolocalizadas
- Integración con calendario para recordatorios

## 🧪 Pruebas

### Casos de Prueba Cubiertos
- ✅ Notificaciones al agregar productos al carrito
- ✅ Notificaciones de confirmación de pedidos
- ✅ Manejo de errores con notificaciones apropiadas
- ✅ Centro de notificaciones funcional
- ✅ Animaciones y transiciones suaves

### Testing Manual Recomendado
1. Agregar producto al carrito sin login → Notificación de error
2. Completar pedido → Notificación de éxito + push
3. Ver centro de notificaciones → Lista completa
4. Marcar notificaciones como leídas → Actualización visual

## 📚 Referencias

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Material Design Notifications](https://material.io/design/communication)

---

**Última actualización**: Noviembre 2025
**Versión**: 1.0.0
**Estado**: ✅ Completo y funcional</content>
<parameter name="filePath">d:\Proyectos\AppsMoviles\saray\docs\notifications_system.md