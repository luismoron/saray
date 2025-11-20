# Sistema de Actualizaciones Automáticas (OTA) - Documentación Técnica

## Resumen
El sistema OTA permite a la aplicación Saray actualizarse automáticamente descargando el APK más reciente desde Google Drive. Debido a las restricciones de seguridad de Google Drive (páginas de advertencia de virus para archivos grandes), se ha implementado un sistema robusto de "scraping" para obtener el enlace de descarga real.

## Arquitectura

### 1. Flujo de Actualización
1.  **Verificación:** La app descarga `version.json` desde Google Drive.
2.  **Comparación:** Compara `version` del JSON con `package_info.version`.
3.  **Descarga:**
    *   Intenta descargar el APK directamente.
    *   Si recibe un HTML (advertencia de virus), parsea el formulario HTML para extraer el token de confirmación (`confirm=xxxx`) y el UUID.
    *   Reconstruye la URL de descarga con los parámetros correctos y reintenta.
4.  **Instalación:**
    *   Usa `FileProvider` para exponer el APK descargado de forma segura.
    *   Lanza un `AndroidIntent` con `FLAG_GRANT_READ_URI_PERMISSION` para solicitar la instalación.

### 2. Configuración Requerida

#### Archivo `version.json` (en Google Drive)
Debe ser un archivo público con este formato:
```json
{
  "version": "1.0.2",
  "release_notes": "Corrección de errores y mejoras de rendimiento.",
  "release_date": "2025-11-20",
  "apk_url": "https://drive.google.com/file/d/TU_ID_DE_ARCHIVO_APK/view?usp=sharing"
}
```

#### Dependencias (`pubspec.yaml`)
```yaml
dependencies:
  dio: ^5.x.x              # Para descargas HTTP avanzadas
  android_intent_plus: ^5.x.x # Para lanzar el instalador de Android
  package_info_plus: ^8.x.x   # Para obtener la versión actual
  permission_handler: ^11.x.x # Para solicitar permisos de instalación
  path_provider: ^2.x.x       # Para rutas de almacenamiento
```

#### Configuración Android (`AndroidManifest.xml`)
Permisos necesarios:
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

Provider para instalación segura (dentro de `<application>`):
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

Archivo `android/app/src/main/res/xml/file_paths.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <external-files-path name="app_files" path="." />
</paths>
```

## Componentes del Código

### `UpdateService` (`lib/services/update_service.dart`)
*   **`checkForUpdate()`**: Descarga y parsea `version.json`.
*   **`downloadAndInstallUpdate()`**: Maneja la lógica compleja de descarga.
    *   Detecta si la descarga es un HTML (< 1MB).
    *   Busca formularios `<form action="...">` y campos ocultos.
    *   Construye la URL final con `confirm=t` y `uuid`.
*   **`_installApk()`**: Gestiona los permisos de Android 14+ y lanza el Intent.

### `UpdateProvider` (`lib/providers/update_provider.dart`)
*   Gestiona el estado (`isChecking`, `isDownloading`, `updateInfo`).
*   Notifica a la UI para mostrar banners o diálogos.

## Solución de Problemas Comunes

### "El widget de actualización no desaparece"
*   **Causa:** La versión en `pubspec.yaml` del APK instalado es igual o menor a la de `version.json`.
*   **Solución:** Asegúrate de incrementar `version` en `pubspec.yaml` ANTES de compilar el APK que subirás a Drive.

### "Error: El archivo descargado es HTML"
*   **Causa:** Google Drive cambió su página de advertencia de virus.
*   **Solución:** Revisar los logs `📄 Contenido (desde body): ...` y ajustar las expresiones regulares en `UpdateService`.

### "Error de análisis del paquete" al instalar
*   **Causa:** Descarga corrupta o incompleta (HTML guardado como APK).
*   **Solución:** El servicio ahora verifica automáticamente si el archivo es HTML antes de intentar instalarlo.
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