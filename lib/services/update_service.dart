import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Información de actualización disponible
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String apkUrl;
  final String releaseNotes;
  final DateTime? releaseDate;
  final String? downloadedApkPath; // Ruta del APK descargado (opcional)

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.apkUrl,
    required this.releaseNotes,
    this.releaseDate,
    this.downloadedApkPath,
  });
}

/// Servicio para manejar actualizaciones automáticas de la aplicación desde Google Drive
class UpdateService {
  // Configuración de Google Drive
  // Para obtener el ID del archivo: compartir el archivo en Google Drive y copiar el ID de la URL
  // Ejemplo: https://drive.google.com/file/d/YOUR_FILE_ID/view?usp=sharing
  // El ID sería: YOUR_FILE_ID
  final String _apkDownloadUrl =
      'https://drive.google.com/uc?export=download&id=13gJ4dpmFoe8-4ZZ1d_KzYDiV7ZowNaMq';
  final String _versionInfoUrl =
      'https://drive.google.com/uc?export=download&id=1NEdgg2zDL1Zr3QK6Oeos5iefTKm9eM4D';

  // Instancia de Dio para las peticiones HTTP
  final Dio _dio = Dio(BaseOptions(headers: {'User-Agent': 'Saray-App'}));

  // Estado de la actualización
  bool _isCheckingUpdate = false;
  bool _isDownloading = false;

  /// Verifica si hay una actualización disponible
  Future<UpdateInfo?> checkForUpdate() async {
    if (_isCheckingUpdate) return null;

    try {
      _isCheckingUpdate = true;

      // Obtener información de la versión actual
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint('🔍 UpdateService: Versión actual: $currentVersion');

      // Obtener información de versión desde Google Drive
      debugPrint('🔍 UpdateService: Descargando info desde: $_versionInfoUrl');
      final versionInfo = await _getVersionInfo();

      if (versionInfo == null) {
        debugPrint('❌ UpdateService: No se pudo obtener información de versión');
        return null;
      }

      final latestVersion = versionInfo['version']?.toString() ?? '';

      debugPrint('🔍 UpdateService: Última versión disponible: $latestVersion');
      debugPrint('🔍 UpdateService: Release notes: ${versionInfo['release_notes']}');

      // Comparar versiones
      final isNewer = _isNewerVersion(latestVersion, currentVersion);
      debugPrint('🔍 UpdateService: Comparando versiones - Latest: $latestVersion, Current: $currentVersion, IsNewer: $isNewer');

      if (isNewer) {
        debugPrint('✅ UpdateService: ¡Nueva versión detectada!');
        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          apkUrl: _apkDownloadUrl,
          releaseNotes: versionInfo['release_notes']?.toString() ?? '',
          releaseDate: DateTime.tryParse(
            versionInfo['release_date']?.toString() ?? '',
          ),
        );
      }

      debugPrint('ℹ️ UpdateService: La app está actualizada');
      return null;
    } catch (e) {
      debugPrint('❌ UpdateService: Error al verificar actualización: $e');
      return null;
    } finally {
      _isCheckingUpdate = false;
    }
  }

  /// Descarga el APK y devuelve la ruta del archivo descargado
  Future<String?> downloadAndInstallUpdate(UpdateInfo updateInfo) async {
    if (_isDownloading) {
      debugPrint('⚠️ Ya hay una descarga en progreso');
      return null;
    }

    try {
      _isDownloading = true;
      debugPrint('🚀 Iniciando descarga e instalación de actualización');

      // Verificar conexión a internet
      try {
        await _dio.get('https://www.google.com');
        debugPrint('🌐 Conexión a internet: OK');
      } catch (e) {
        debugPrint('❌ Sin conexión a internet: $e');
        throw Exception('Sin conexión a internet. Verifica tu conexión WiFi/datos.');
      }

      // Solicitar permisos necesarios
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        debugPrint('❌ No se concedieron los permisos necesarios');
        throw Exception('Permisos denegados. Necesitas conceder permisos de instalación.');
      }

      debugPrint('⬇️ Descargando APK desde: ${updateInfo.apkUrl}');

      // Obtener directorio de descargas
      final downloadDir = await _getDownloadDirectory();
      final apkFileName = 'saray-update-${updateInfo.latestVersion}.apk';
      final apkFile = File('${downloadDir.path}/$apkFileName');

      debugPrint('📁 Directorio de descarga: ${downloadDir.path}');
      debugPrint('📄 Archivo APK: ${apkFile.path}');

      // Descargar el APK
      await _dio.download(
        updateInfo.apkUrl,
        apkFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('⬇️ Progreso: $progress% ($received/$total bytes)');
          }
        },
      );

      debugPrint('✅ APK descargado exitosamente en: ${apkFile.path}');

      // Verificar que el archivo existe y tiene contenido
      if (await apkFile.exists()) {
        final fileSize = await apkFile.length();
        debugPrint('📊 Tamaño del archivo descargado: $fileSize bytes');
      } else {
        debugPrint('❌ El archivo descargado no existe');
        return null;
      }

      // Crear intent para instalar el APK automáticamente
      try {
        debugPrint('🔄 Iniciando instalación automática del APK...');

        // Para Android moderno, usar ACTION_INSTALL_PACKAGE si está disponible
        final intent = AndroidIntent(
          action: 'android.intent.action.INSTALL_PACKAGE',
          data: 'file://${apkFile.path}',
          type: 'application/vnd.android.package-archive',
          flags: <int>[
            Flag.FLAG_ACTIVITY_NEW_TASK,
            Flag.FLAG_GRANT_READ_URI_PERMISSION,
          ],
        );

        debugPrint('📱 Enviando intent de instalación: ${intent.action}');
        await intent.launch();

        debugPrint('✅ Intent de instalación enviado exitosamente');
        debugPrint('📋 El sistema debería mostrar el diálogo de instalación automáticamente');

        return apkFile.path;
      } catch (e) {
        debugPrint('❌ Error al crear intent de instalación automática: $e');

        // Fallback: intentar con ACTION_VIEW (más compatible)
        try {
          debugPrint('🔄 Intentando fallback con ACTION_VIEW...');
          final fallbackIntent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: 'file://${apkFile.path}',
            type: 'application/vnd.android.package-archive',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await fallbackIntent.launch();
          debugPrint('✅ Fallback intent enviado exitosamente');
          return apkFile.path;
        } catch (fallbackError) {
          debugPrint('❌ Error en fallback intent: $fallbackError');
          return null;
        }
      }
    } catch (e) {
      debugPrint('Error al descargar APK: $e');
      return null;
    } finally {
      _isDownloading = false;
    }
  }

  /// Solicita permisos necesarios para la instalación
  Future<bool> _requestPermissions() async {
    try {
      debugPrint('🔐 Solicitando permisos de instalación...');

      // Solicitar permiso de instalación de paquetes
      final installPermission = await Permission.requestInstallPackages.request();
      debugPrint('🔐 Permiso de instalación: ${installPermission.isGranted}');

      // Solicitar permiso de almacenamiento (para Android < 13)
      final storagePermission = await Permission.storage.request();
      debugPrint('🔐 Permiso de almacenamiento: ${storagePermission.isGranted}');

      // Para Android 13+ también solicitar permiso de fotos/videos
      final photosPermission = await Permission.photos.request();
      debugPrint('🔐 Permiso de fotos: ${photosPermission.isGranted}');

      final hasPermissions = installPermission.isGranted &&
          (storagePermission.isGranted || photosPermission.isGranted);

      debugPrint('🔐 Todos los permisos concedidos: $hasPermissions');
      return hasPermissions;
    } catch (e) {
      debugPrint('❌ Error al solicitar permisos: $e');
      return false;
    }
  }

  /// Obtiene el directorio de descargas
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, usar el directorio de descargas público
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else {
      // Para otras plataformas, usar el directorio temporal
      return await getTemporaryDirectory();
    }
  }

  /// Obtiene información de versión (primero intenta Google Drive, luego assets como fallback)
  Future<Map<String, dynamic>?> _getVersionInfo() async {
    // Primero intentar descargar desde Google Drive
    try {
      debugPrint('🔍 _getVersionInfo: Intentando descargar version.json desde Google Drive');

      final response = await _dio.get(_versionInfoUrl);
      if (response.statusCode == 200) {
        final content = response.data.toString();
        debugPrint('✅ _getVersionInfo: Datos obtenidos desde Google Drive: $content');

        final data = json.decode(content) as Map<String, dynamic>;
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ _getVersionInfo: No se pudo descargar desde Google Drive, usando fallback: $e');
    }

    // Fallback: leer desde assets
    try {
      debugPrint('🔍 _getVersionInfo: Usando version.json desde assets como fallback');

      final content = await rootBundle.loadString('version.json');
      debugPrint('🔍 _getVersionInfo: Contenido desde assets: $content');

      final data = json.decode(content) as Map<String, dynamic>;
      debugPrint('✅ _getVersionInfo: Datos obtenidos desde assets: $data');
      return data;
    } catch (e) {
      debugPrint('❌ _getVersionInfo: Error al leer desde assets: $e');
      return null;
    }
  }

  /// Compara versiones para determinar si la nueva es más reciente
  bool _isNewerVersion(String latestVersion, String currentVersion) {
    try {
      final latestParts = latestVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      // Comparar versión mayor
      if (latestParts[0] > currentParts[0]) return true;
      if (latestParts[0] < currentParts[0]) return false;

      // Comparar versión menor
      if (latestParts[1] > currentParts[1]) return true;
      if (latestParts[1] < currentParts[1]) return false;

      // Comparar versión de parche
      if (latestParts[2] > currentParts[2]) return true;

      return false;
    } catch (e) {
      debugPrint('Error al comparar versiones: $e');
      return false;
    }
  }

  /// Descarga el APK sin instalarlo automáticamente
  Future<String?> downloadApkOnly(UpdateInfo updateInfo) async {
    if (_isDownloading) return null;

    try {
      _isDownloading = true;

      // Solicitar permisos necesarios
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        debugPrint('❌ UpdateService: No se concedieron los permisos necesarios');
        return null;
      }

      debugPrint('⬇️ UpdateService: Descargando APK desde: ${updateInfo.apkUrl}');

      // Obtener directorio de descargas
      final downloadDir = await _getDownloadDirectory();
      final apkFileName = 'saray-update-${updateInfo.latestVersion}.apk';
      final apkFile = File('${downloadDir.path}/$apkFileName');

      // Descargar el APK
      await _dio.download(
        updateInfo.apkUrl,
        apkFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint('⬇️ UpdateService: Progreso: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      debugPrint('✅ UpdateService: APK descargado en: ${apkFile.path}');
      return apkFile.path;
    } catch (e) {
      debugPrint('❌ UpdateService: Error al descargar APK: $e');
      return null;
    } finally {
      _isDownloading = false;
    }
  }
}
