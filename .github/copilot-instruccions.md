# Instrucciones para Copilot - Proyecto Saray

## Reglas Generales del Proyecto

### 🚀 Despliegue y Distribución
- **Script de despliegue**: Utilizar `./deploy.bat` para construir APK y copiar archivos a Google Drive
- **Comando**: `.\deploy.bat` (desde PowerShell/Windows Terminal)
- **Función**: Construye APK en modo debug y copia automáticamente a carpeta de Google Drive
- **Archivos copiados**: `app-debug.apk` y `version.json`
- **Ubicación destino**: `G:\Mi unidad\Apk-test\` (Google Drive)

### 📱 Sistema de Actualizaciones OTA
- **Detección automática**: Se ejecuta al iniciar la app
- **Lectura de versión**: Desde `version.json` en assets del APK
- **Descarga**: Desde Google Drive usando URLs públicas
- **Instalación**: Automática después de descarga (requiere permisos)
- **Permisos requeridos**: `REQUEST_INSTALL_PACKAGES` en Android

### 🔧 Comandos Flutter Comunes
- **Construir APK debug**: `flutter build apk --debug`
- **Construir APK release**: `flutter build apk --release`
- **Limpiar build**: `flutter clean`
- **Obtener dependencias**: `flutter pub get`
- **Análisis de código**: `flutter analyze`

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
1. Actualizar `version.json` con nueva versión y notas de release
2. Ejecutar `./deploy.bat` para construir y copiar archivos
3. Verificar que Google Drive sincronice los archivos
4. Probar actualización OTA en dispositivo físico

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