import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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

      debugPrint('Versión actual: $currentVersion');

      // Obtener información de versión desde Google Drive
      final versionInfo = await _getVersionInfo();

      if (versionInfo == null) {
        debugPrint('No se pudo obtener información de versión');
        return null;
      }

      final latestVersion = versionInfo['version']?.toString() ?? '';

      debugPrint('Última versión disponible: $latestVersion');

      // Comparar versiones
      if (_isNewerVersion(latestVersion, currentVersion)) {
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

      return null;
    } catch (e) {
      debugPrint('Error al verificar actualización: $e');
      return null;
    } finally {
      _isCheckingUpdate = false;
    }
  }

  /// Descarga el APK y devuelve la ruta del archivo descargado
  Future<String?> downloadAndInstallUpdate(UpdateInfo updateInfo) async {
    if (_isDownloading) return null;

    try {
      _isDownloading = true;

      // Solicitar permisos necesarios
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        debugPrint('No se concedieron los permisos necesarios');
        return null;
      }

      debugPrint('Descargando APK desde: ${updateInfo.apkUrl}');

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
            debugPrint('Progreso: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      debugPrint('APK descargado en: ${apkFile.path}');

      // Crear intent para instalar el APK automáticamente
      try {
        final intent = AndroidIntent(
          action: 'action_view',
          data: 'file://${apkFile.path}',
          type: 'application/vnd.android.package-archive',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        debugPrint('Intent de instalación enviado exitosamente');
        return apkFile.path;
      } catch (e) {
        debugPrint('Error al crear intent de instalación: $e');
        return null;
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
      // Solicitar permiso de instalación de paquetes
      final installPermission = await Permission.requestInstallPackages
          .request();

      // Solicitar permiso de almacenamiento (para Android < 13)
      final storagePermission = await Permission.storage.request();

      // Para Android 13+ también solicitar permiso de fotos/videos
      final photosPermission = await Permission.photos.request();

      return installPermission.isGranted &&
          (storagePermission.isGranted || photosPermission.isGranted);
    } catch (e) {
      debugPrint('Error al solicitar permisos: $e');
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

  /// Obtiene información de versión desde Google Drive
  Future<Map<String, dynamic>?> _getVersionInfo() async {
    try {
      final response = await _dio.get(_versionInfoUrl);

      if (response.statusCode == 200) {
        // Si es un archivo JSON directo
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }

        // Si es un string JSON, parsearlo
        if (response.data is String) {
          return json.decode(response.data as String) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error al obtener información de versión: $e');
    }
    return null;
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

  /// Verifica si se está verificando una actualización
  bool get isCheckingUpdate => _isCheckingUpdate;

  /// Verifica si se está descargando una actualización
  bool get isDownloading => _isDownloading;
}
