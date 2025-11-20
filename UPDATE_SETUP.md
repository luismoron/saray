# Configuración de Actualizaciones Automáticas desde Google Drive

Este documento explica cómo configurar el sistema de actualizaciones automáticas para testers usando Google Drive.

## 📋 Requisitos Previos

1. **Cuenta de Google Drive** con permisos para compartir archivos
2. **Archivo APK** de la aplicación
3. **Archivo JSON** con información de versión

## 🚀 Configuración

### 1. Preparar el Archivo JSON de Versión

Crea un archivo `version.json` con el siguiente formato:

```json
{
  "version": "1.0.1",
  "release_notes": "• Nueva funcionalidad de actualizaciones automáticas\n• Corrección de bugs menores\n• Mejoras en el rendimiento",
  "release_date": "2025-11-20"
}
```

**Campos del JSON:**
- `version`: Versión de la app (formato: major.minor.patch)
- `release_notes`: Notas del release (pueden incluir emojis y saltos de línea con \n)
- `release_date`: Fecha del release (formato: YYYY-MM-DD)

### 2. Subir Archivos a Google Drive

1. **Subir el APK:**
   - Sube tu archivo `app-debug.apk` a Google Drive
   - Haz clic derecho → "Obtener enlace"
   - Cambia los permisos a "Cualquier persona con el enlace puede ver"
   - Copia el ID del archivo de la URL

2. **Subir el JSON de versión:**
   - Sube tu archivo `version.json` a Google Drive
   - Repite el mismo proceso de compartir

### 3. Configurar URLs en el Código

En `lib/services/update_service.dart`, actualiza estas líneas:

```dart
final String _apkDownloadUrl = 'https://drive.google.com/uc?export=download&id=13gJ4dpmFoe8-4ZZ1d_KzYDiV7ZowNaMq';
final String _versionInfoUrl = 'https://drive.google.com/uc?export=download&id=1NEdgg2zDL1Zr3QK6Oeos5iefTKm9eM4D';
```

**Ejemplo:**
```dart
final String _apkDownloadUrl = 'https://drive.google.com/uc?export=download&id=1ABC123def456GHI789';
final String _versionInfoUrl = 'https://drive.google.com/uc?export=download&id=1NEdgg2zDL1Zr3QK6Oeos5iefTKm9eM4D';
```

## 📱 Integración en la App

### Uso Básico

```dart
import 'package:saray/services/update_service.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await _updateService.checkForUpdate();

    if (updateInfo != null) {
      // Mostrar diálogo de actualización
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva versión disponible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión ${updateInfo.latestVersion}'),
            SizedBox(height: 8),
            Text('Novedades:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(updateInfo.releaseNotes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Después'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _updateService.downloadAndInstallUpdate(updateInfo);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Descargando actualización...')),
                );
              }
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... tu configuración de MaterialApp
    );
  }
}
```

### Verificación Automática

Para verificar actualizaciones automáticamente al iniciar la app:

```dart
@override
void initState() {
  super.initState();
  // Verificar actualizaciones después de que la app esté completamente cargada
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkForUpdates();
  });
}
```

## 🔧 Actualización de Versiones

### Proceso para Nueva Versión

1. **Actualizar el código de la app**
2. **Incrementar la versión** en `pubspec.yaml`
3. **Generar nuevo APK**: `flutter build apk --debug`
4. **Actualizar version.json** con la nueva versión y notas
5. **Subir nuevo APK** a Google Drive (reemplazar el anterior)
6. **Actualizar version.json** en Google Drive

### Formato de Versiones

Usa [Semantic Versioning](https://semver.org/):
- `1.0.0`: Versión inicial
- `1.0.1`: Corrección de bug
- `1.1.0`: Nueva funcionalidad
- `2.0.0`: Cambio mayor

## 🐛 Solución de Problemas

### Error de permisos
Asegúrate de que los archivos en Google Drive estén compartidos como "Cualquier persona con el enlace puede ver".

### APK no se descarga
Verifica que el ID del archivo APK sea correcto y que el archivo no esté corrupto.

### JSON mal formateado
Valida tu JSON usando [JSONLint](https://jsonlint.com/) antes de subirlo.

### Actualización no detectada
- Verifica que la versión en `version.json` sea mayor que la versión actual de la app
- Revisa los logs en la consola para errores

## 📋 Checklist de Configuración

- [ ] Archivo `version.json` creado y validado
- [ ] APK subido a Google Drive y compartido
- [ ] JSON de versión subido a Google Drive y compartido
- [ ] IDs de archivos configurados en `update_service.dart`
- [ ] Permisos agregados al `AndroidManifest.xml`
- [ ] Servicio integrado en la app
- [ ] Probado en dispositivo real

## 🔒 Seguridad

- Los archivos en Google Drive deben estar compartidos de forma pública para que los testers puedan descargarlos
- Considera usar enlaces temporales o restringir el acceso por dominio si es necesario
- No incluyas información sensible en el JSON de versión

## ⚡ Instalación Automática

### Cómo Funciona

El sistema implementa **instalación automática** del APK usando intents de Android:

1. **Descarga**: El APK se descarga automáticamente desde Google Drive
2. **Intent del Sistema**: Se crea un intent de Android para abrir el instalador
3. **Instalador Automático**: El instalador del sistema Android se abre automáticamente
4. **Confirmación**: El usuario solo confirma la instalación (requerido por Android)

### Flujo Completo para Testers

1. **Apertura de App**: La app verifica actualizaciones automáticamente
2. **Notificación**: Aparece banner/dialog si hay nueva versión
3. **Un Clic**: Usuario hace clic en "Instalar Actualización"
4. **Descarga**: APK se descarga en segundo plano
5. **Instalador**: Se abre automáticamente el instalador del sistema
6. **Confirmación**: Usuario confirma instalación (1 clic)
7. **Reinicio**: App se reinicia con la nueva versión

### Requisitos del Dispositivo

- **Android 8.0+**: Compatible con intents de instalación
- **Fuentes Desconocidas**: Primera vez requiere activar "Instalar apps desconocidas"
- **Permisos**: App solicita permisos automáticamente

### Beneficios

- ✅ **Un solo clic** para actualizar
- ✅ **Instalación automática** del APK
- ✅ **Sin navegación manual** por carpetas
- ✅ **Experiencia fluida** para testers