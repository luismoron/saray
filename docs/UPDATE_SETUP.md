# Sistema de Actualizaciones Automáticas (OTA) - Guía de Configuración

## Resumen
El sistema OTA permite actualizaciones automáticas de la aplicación Saray mediante verificación de versiones desde Google Drive y descarga manual de APKs.

## Arquitectura del Sistema

### Componentes Principales
1. **UpdateService** (`lib/services/update_service.dart`)
   - Verifica versiones disponibles desde Google Drive
   - Compara versión actual vs versión remota
   - Gestiona descargas de APK

2. **UpdateProvider** (`lib/providers/update_provider.dart`)
   - Maneja estado de actualizaciones en la UI
   - Controla visibilidad de notificaciones

3. **UI Components**
   - Banner de actualización en pantalla principal
   - Botón contextual en AppBar
   - Diálogo de detalles de versión

4. **Archivos de Configuración**
   - `version.json`: Información de versión y notas de release
   - `pubspec.yaml`: Inclusión de assets

## Configuración Inicial

### 1. Archivo version.json
Crear el archivo `version.json` en la raíz del proyecto:

```json
{
  "version": "1.0.2",
  "release_notes": "Nueva versión con mejoras de rendimiento y corrección de bugs menores.",
  "release_date": "2025-11-20"
}
```

### 2. Inclusión en Assets
Asegurar que `version.json` esté incluido en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - version.json
```

### 3. Dependencias Requeridas
Verificar en `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  android_intent_plus: ^5.0.0
  package_info_plus: ^8.0.0
  permission_handler: ^11.3.0
```

## Implementación del Servicio

### UpdateService
```dart
class UpdateService {
  static const String _versionUrl = 'https://drive.google.com/uc?export=download&id=YOUR_VERSION_FILE_ID';
  static const String _apkUrl = 'https://drive.google.com/uc?export=download&id=YOUR_APK_FILE_ID';

  Future<VersionInfo?> checkForUpdates() async {
    try {
      // Leer versión local desde assets
      final localVersion = await _getLocalVersion();

      // Leer versión remota desde Google Drive
      final remoteVersion = await _getRemoteVersion();

      if (remoteVersion != null && _isNewerVersion(remoteVersion.version, localVersion)) {
        return remoteVersion;
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  Future<String> _getLocalVersion() async {
    final jsonString = await rootBundle.loadString('version.json');
    final jsonData = json.decode(jsonString);
    return jsonData['version'];
  }

  Future<VersionInfo?> _getRemoteVersion() async {
    final response = await Dio().get(_versionUrl);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.data);
      return VersionInfo.fromJson(jsonData);
    }
    return null;
  }

  bool _isNewerVersion(String remoteVersion, String localVersion) {
    // Lógica de comparación de versiones
    return _compareVersions(remoteVersion, localVersion) > 0;
  }

  Future<void> downloadAndInstallApk(BuildContext context) async {
    // Implementación de descarga e instalación
  }
}
```

## Integración en la UI

### Provider Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final updateProvider = UpdateProvider();
  await updateProvider.checkForUpdates();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => updateProvider),
        // otros providers...
      ],
      child: const MyApp(),
    ),
  );
}
```

### Banner de Notificación
```dart
class UpdateBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        if (!updateProvider.hasUpdate) return const SizedBox.shrink();

        return MaterialBanner(
          content: Text('Nueva versión disponible: ${updateProvider.versionInfo?.version}'),
          actions: [
            TextButton(
              onPressed: () => updateProvider.showUpdateDialog(context),
              child: const Text('Ver detalles'),
            ),
            TextButton(
              onPressed: () => updateProvider.dismissUpdate(),
              child: const Text('Después'),
            ),
          ],
        );
      },
    );
  }
}
```

## Distribución y Despliegue

### Script deploy.bat
```batch
@echo off
echo Building APK...
flutter build apk --release

echo Copying APK to Google Drive folder...
copy build\app\outputs\flutter-apk\app-release.apk "C:\Google Drive\Saray\apk\app-release.apk"

echo Copying version.json to Google Drive...
copy version.json "C:\Google Drive\Saray\version.json"

echo Deployment complete!
pause
```

### Configuración de Google Drive
1. Crear carpeta compartida "Saray" en Google Drive
2. Subir APK y version.json
3. Obtener IDs de archivos para URLs de descarga
4. Configurar permisos de acceso público

## Solución de Problemas

### Problema: No se detectan actualizaciones
**Síntomas**: El banner de actualización no aparece
**Causa**: version.json no incluido en assets
**Solución**: Verificar pubspec.yaml incluye `- version.json`

### Problema: Error al leer versión local
**Síntomas**: Excepción al cargar rootBundle
**Causa**: Archivo no existe o ruta incorrecta
**Solución**: Verificar existencia de version.json en assets

### Problema: Descarga falla
**Síntomas**: Error de red al descargar APK
**Causa**: URL incorrecta o permisos insuficientes
**Solución**: Verificar URLs de Google Drive y permisos de archivo

## Mejores Prácticas

1. **Versionado Semántico**: Usar formato MAJOR.MINOR.PATCH
2. **Notas de Release**: Mantener concisas y descriptivas
3. **Testing**: Probar actualizaciones en dispositivos reales
4. **Backup**: Mantener versiones anteriores del APK
5. **Monitoreo**: Registrar logs de actualización para debugging

## Próximos Pasos

- [ ] Implementar actualizaciones automáticas (sin intervención del usuario)
- [ ] Agregar checksums para verificar integridad de descargas
- [ ] Soporte para actualizaciones delta (solo cambios)
- [ ] Analytics de adopción de versiones
- [ ] Sistema de rollback para versiones problemáticas