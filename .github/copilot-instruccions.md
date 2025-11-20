# Instrucciones para Copilot - Proyecto Saray

## Reglas Generales del Proyecto

### 🚀 Despliegue y Distribución
- **Script de despliegue**: Utilizar `./deploy.bat` para construir APK y copiar archivos a Google Drive
- **Comando**: `.\deploy.bat` (desde PowerShell/Windows Terminal)
- **Función**: Construye APK en modo debug y copia automáticamente a carpeta de Google Drive
- **Archivos copiados**: `app-debug.apk` y `version.json`
- **Ubicación destino**: `G:\Mi unidad\Apk-test\` (Google Drive)

#### 📋 Comandos Especiales de Despliegue
- **deploy-tester**: Cuando el usuario indique específicamente "deploy-tester" o "haz deploy para testers"
  - Construir APK en modo debug
  - Copiar APK y version.json a Google Drive
  - **NO ejecutar automáticamente** - solo cuando el usuario lo solicite explícitamente
  - Usar `./deploy.bat` para esta operación

### 📱 Sistema de Actualizaciones OTA
- **Detección automática**: Se ejecuta al iniciar la app
- **Lectura de versión**: Desde `version.json` en assets del APK
- **Descarga**: Desde Google Drive usando URLs públicas
- **Instalación**: **COMPLETAMENTE AUTOMÁTICA** - El usuario solo acepta
- **Permisos requeridos**: `REQUEST_INSTALL_PACKAGES` en Android

### 🔧 Comandos Flutter Comunes
- **Construir APK debug**: `flutter build apk --debug`
- **Construir APK release**: `flutter build apk --release`
- **Limpiar build**: `flutter clean`
- **Obtener dependencias**: `flutter pub get`
- **Análisis de código**: `flutter analyze`

#### 🎯 Comando Específico para Pruebas
- **Ejecutar app en desarrollo**: `flutter run -d "TECNO LH7n"`
- **Solo cuando se indique**: Ejecutar únicamente cuando el usuario diga "iniciemos pruebas", "corre la app", "prueba en el dispositivo", etc.
- **Dispositivo específico**: TECNO LH7n (no usar otros dispositivos automáticamente)
- **NO ejecutar automáticamente**: Nunca ejecutar `flutter run` sin instrucción explícita del usuario

### 🔄 Hot Reload y Desarrollo Interactivo
- **Hot Reload por defecto**: Usar `r` en la terminal de Flutter para hot reload (cambios de UI)
- **Hot Restart**: Usar `R` (mayúscula) para hot restart (cambios de lógica/state)
- **Full Restart**: Usar `q` para salir y `flutter run -d "TECNO LH7n"` para reinicio completo
- **Preferencia**: Siempre intentar hot reload/restart antes de full restart
- **Flujo de desarrollo**: Ejecutar app → hacer cambios → hot reload → continuar

#### 💡 Mejores Prácticas de Desarrollo
- **Cambios de UI**: Solo hot reload (`r`) - colores, textos, layouts
- **Cambios de lógica**: Hot restart (`R`) - funciones, state management, navegación
- **Cambios estructurales**: Full restart - nuevas dependencias, cambios en main.dart
- **Debugging**: Usar hot reload para probar fixes rápidamente
- **Productividad**: Mantener la app corriendo y usar reload para iteraciones rápidas

### ⌨️ Comandos Interactivos en Desarrollo
Durante `flutter run`, usar estos comandos en la terminal:
- **`r`**: Hot Reload (cambios de UI, más rápido)
- **`R`**: Hot Restart (cambios de lógica, reinicia state)
- **`q`**: Salir de la aplicación
- **`h`**: Mostrar ayuda de comandos disponibles
- **`p`**: Captura screenshot del dispositivo
- **`t`**: Toggle debug painting (ver layouts)

### 🚀 Flujo de Trabajo en Desarrollo
1. **Inicio**: Usuario dice "iniciemos pruebas" → ejecutar `flutter run -d "TECNO LH7n"`
2. **Desarrollo**: Hacer cambios en el código
3. **Actualización**: Usar `r` (hot reload) para ver cambios inmediatamente
4. **Si no funciona**: Usar `R` (hot restart) para reiniciar lógica
5. **Debugging**: Usar comandos interactivos (`p`, `t`) según necesite
6. **Reinicio completo**: Solo cuando sea necesario (cambios estructurales)
7. **Cierre**: Usar `q` para salir cuando termine la sesión

**Regla de oro**: Mantener la app corriendo tanto tiempo como sea posible y usar reload para desarrollo rápido.

### 🎮 Comandos de Usuario para Pruebas
Cuando el usuario diga cualquiera de estos comandos, ejecutar `flutter run -d "TECNO LH7n"`:
- "iniciemos pruebas"
- "corre la app"
- "prueba en el dispositivo"
- "ejecuta la aplicación"
- "flutter run"
- "pruebas en TECNO"

**Regla crítica**: Nunca ejecutar `flutter run` automáticamente. Siempre esperar instrucción explícita del usuario.

### ⚡ Comportamiento Esperado para Pruebas
- **Por defecto**: NO ejecutar `flutter run` automáticamente
- **Solo cuando se solicite**: Ejecutar pruebas únicamente con comandos explícitos del usuario
- **Dispositivo fijo**: Siempre usar `-d "TECNO LH7n"`
- **Confirmación**: Informar al usuario antes de ejecutar cualquier comando de prueba

### 📂 Estructura de Archivos
- **Assets**: `version.json` debe estar incluido en `pubspec.yaml`
- **Configuración**: `pubspec.yaml` para dependencias y assets
- **Documentación**: `docs/` contiene toda la documentación técnica
- **Scripts**: `deploy.bat` para automatización de despliegue

### 🔒 Seguridad y Permisos
- **Android**: Permisos de instalación y almacenamiento configurados en `AndroidManifest.xml`
- **Google Drive**: Archivos compartidos públicamente para descarga OTA
- **Firebase**: Configurado para autenticación y base de datos

### 📋 Checklist de Despliegue
**⚠️ IMPORTANTE: Solo ejecutar cuando el usuario indique "deploy-tester" o similar**
1. Esperar instrucción explícita del usuario ("deploy-tester", "haz deploy", etc.)
2. Actualizar `version.json` con nueva versión y notas de release (si aplica)
3. Ejecutar `./deploy.bat` para construir y copiar archivos
4. Verificar que Google Drive sincronice los archivos
5. **NO ejecutar automáticamente** - siempre esperar confirmación del usuario

### 🎯 Comandos de Usuario para Despliegue
Cuando el usuario diga cualquiera de estos comandos, ejecutar `./deploy.bat`:
- "deploy-tester"
- "haz deploy"
- "deploy para testers"
- "sube la versión"
- "construye y despliega"
- "deploy.bat"

**Regla importante**: Nunca ejecutar despliegue automáticamente. Siempre esperar instrucción explícita del usuario.

### ⚡ Comportamiento Esperado
- **Por defecto**: NO ejecutar `./deploy.bat` automáticamente
- **Solo cuando se solicite**: Ejecutar despliegue únicamente con comandos explícitos del usuario
- **Confirmación**: Siempre informar al usuario antes de ejecutar cualquier despliegue

### 🐛 Debugging OTA
- **Logs**: Revisar logs de Flutter para mensajes de `UpdateService`
- **Permisos**: Verificar que se concedan permisos de instalación
- **URLs**: Confirmar que las URLs de Google Drive sean accesibles
- **Versión**: Verificar comparación correcta de versiones semánticas

### 📚 Documentación Técnica
- `docs/UPDATE_SETUP.md`: Guía completa del sistema OTA
- `docs/docs.md`: Resumen general del proyecto
- `docs/project_summary.md`: Resumen ejecutivo del proyecto

## Notas Importantes
- Siempre usar `./deploy.bat` en lugar de comandos manuales para despliegue
- Mantener `version.json` actualizado antes de cada release
- Probar actualizaciones OTA en dispositivos reales, no solo emuladores
- Los permisos de Android pueden requerir configuración adicional en algunos dispositivos