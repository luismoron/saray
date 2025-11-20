# Guía Maestra: Implementación de Actualizaciones OTA con Google Drive en Flutter

Este documento detalla paso a paso cómo implementar un sistema de actualizaciones automáticas (OTA) utilizando Google Drive como servidor de archivos. Esta guía está diseñada para ser replicable en cualquier proyecto Flutter.

---

## 1. Dependencias (`pubspec.yaml`)

Agrega las siguientes librerías para manejar descargas, información de paquete, permisos e instalación.

```yaml
dependencies:
  dio: ^5.4.0              # Cliente HTTP potente para descargas
  package_info_plus: ^8.0.0   # Para obtener la versión actual de la app
  android_intent_plus: ^5.0.0 # Para lanzar el instalador de APK en Android
  permission_handler: ^11.3.0 # Para solicitar permisos de almacenamiento/instalación
  path_provider: ^2.1.2       # Para ubicar dónde guardar el APK
  flutter:
    sdk: flutter
```

---

## 2. Configuración de Android

### A. Permisos (`android/app/src/main/AndroidManifest.xml`)
Añade estos permisos antes de la etiqueta `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### B. Configuración de FileProvider
Para instalar APKs en Android 7+ (y especialmente Android 14+), necesitas un `FileProvider`.

1. **En `AndroidManifest.xml`**, dentro de `<application>`:

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

2. **Crear archivo `android/app/src/main/res/xml/file_paths.xml`**:
(Si la carpeta `xml` no existe, créala).

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <external-files-path name="app_files" path="." />
</paths>
```

---

## 3. Configuración en Google Drive

### A. Archivo de Control (`version.json`)
Crea un archivo JSON localmente y súbelo a Drive. Este archivo le dirá a la app si hay una nueva versión.

```json
{
  "version": "1.0.1",
  "release_notes": "Mejoras de rendimiento y corrección de errores.",
  "apk_url": "https://drive.google.com/file/d/TU_ID_DEL_APK_AQUI/view?usp=sharing"
}
```

### B. Subir Archivos y Obtener IDs
1. Sube `version.json` a Drive.
2. Sube tu archivo `.apk` a Drive.
3. **IMPORTANTE:** Haz clic derecho en ambos archivos -> Compartir -> Acceso general: **"Cualquier persona con el enlace"**.
4. Copia el ID del archivo `version.json` (la cadena larga de letras y números en el enlace). Lo necesitarás en el código.

---

## 4. Lógica del Servicio (`UpdateService`)

El desafío principal con Drive es que para archivos grandes (>100MB) o ejecutables, muestra una página de advertencia de virus en lugar de descargar el archivo. **Esta lógica soluciona eso mediante scraping.**

Crea `lib/services/update_service.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class UpdateService {
  // ID del archivo version.json en Drive
  final String _driveVersionFileId = 'PON_AQUI_EL_ID_DEL_VERSION_JSON';
  final Dio _dio = Dio();

  /// Convierte ID de Drive a URL de descarga directa
  String _getDriveDownloadUrl(String id) {
    return 'https://drive.google.com/uc?export=download&id=$id&confirm=t';
  }

  /// Verifica actualizaciones
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final url = _getDriveDownloadUrl(_driveVersionFileId);
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final jsonInfo = (response.data is String) ? json.decode(response.data) : response.data;
        
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        final latestVersion = jsonInfo['version'];

        if (_isNewer(latestVersion, currentVersion)) {
          return jsonInfo;
        }
      }
    } catch (e) {
      debugPrint('Error verificando actualización: $e');
    }
    return null;
  }

  /// Lógica Maestra: Descarga con Bypass de Advertencia de Virus
  Future<void> downloadAndInstall(String apkDriveUrl) async {
    // 1. Preparar ruta
    final dir = await getExternalStorageDirectory();
    final savePath = '${dir!.path}/update.apk';
    
    // Extraer ID del APK
    String fileId = '';
    final uri = Uri.parse(apkDriveUrl);
    if (uri.queryParameters.containsKey('id')) fileId = uri.queryParameters['id']!;
    else if (uri.pathSegments.contains('d')) fileId = uri.pathSegments[uri.pathSegments.indexOf('d') + 1];

    String downloadUrl = 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';

    // 2. Descargar
    await _dio.download(downloadUrl, savePath);

    // 3. Verificar si es HTML (Advertencia de Virus)
    final file = File(savePath);
    if ((await file.length()) < 1024 * 1024) { // Menos de 1MB
      final content = await file.readAsString();
      if (content.contains('<html')) {
        debugPrint('⚠️ Detectada advertencia de virus. Aplicando bypass...');
        
        // ESTRATEGIA DE BYPASS: Parsear formulario
        String? confirmUrl;
        
        // Buscar form action
        final formRegex = RegExp(r'<form[^>]*action="([^"]+)"[^>]*>(.*?)</form>', dotAll: true);
        final formMatch = formRegex.firstMatch(content);
        
        if (formMatch != null) {
           String action = formMatch.group(1)!.replaceAll('&amp;', '&');
           String body = formMatch.group(2)!;
           
           // Extraer inputs hidden
           final inputRegex = RegExp(r'name="([^"]+)"\s+value="([^"]+)"');
           final params = <String>[];
           for (final m in inputRegex.allMatches(body)) {
             params.add('${m.group(1)}=${m.group(2)}');
           }
           
           confirmUrl = '$action?${params.join('&')}';
        }

        if (confirmUrl != null) {
           debugPrint('🔄 Reintentando con token extraído...');
           await _dio.download(confirmUrl, savePath);
        } else {
           throw Exception('No se pudo saltar la advertencia de virus de Drive.');
        }
      }
    }

    // 4. Instalar
    await _installApk(savePath);
  }

  Future<void> _installApk(String path) async {
    if (await Permission.requestInstallPackages.request().isGranted) {
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = 'content://${packageInfo.packageName}.fileprovider/app_files/update.apk';
      
      await AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: uri,
        type: 'application/vnd.android.package-archive',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_GRANT_READ_URI_PERMISSION],
      ).launch();
    }
  }

  bool _isNewer(String v1, String v2) {
    // Implementar comparación semántica (ej. 1.0.2 > 1.0.1)
    return v1.compareTo(v2) > 0; // Simplificado
  }
}
```

---

## 5. Integración en UI

Simplemente llama al servicio desde un botón o al iniciar la app:

```dart
final updateService = UpdateService();
final info = await updateService.checkForUpdate();

if (info != null) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Actualización ${info['version']}'),
      content: Text(info['release_notes']),
      actions: [
        TextButton(
          child: Text('Actualizar'),
          onPressed: () {
            Navigator.pop(ctx);
            updateService.downloadAndInstall(info['apk_url']);
          },
        )
      ],
    ),
  );
}
```

## Resumen de "Trucos" Clave
1. **Bypass de Virus:** Google Drive devuelve un HTML con un formulario oculto cuando el archivo es grande. El código debe detectar esto (archivo pequeño + contenido HTML) y parsear el `action` y los `input` del formulario para obtener el enlace real.
2. **FileProvider:** Android moderno no deja instalar archivos directamente desde `file://`. Debes usar `content://` a través de un FileProvider configurado en el Manifest.
3. **Versiones:** Siempre sube un APK con `version` en `pubspec.yaml` MAYOR a la que tiene el usuario, y actualiza el `version.json` acorde.
