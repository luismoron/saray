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
import 'package:path/path.dart' as path;

/// Información de actualización disponible
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String apkUrl;
  final String releaseNotes;
  final DateTime? releaseDate;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.apkUrl,
    required this.releaseNotes,
    this.releaseDate,
  });
}

/// Servicio para manejar actualizaciones automáticas de la aplicación desde Google Drive
class UpdateService {
  // ==========================================================================
  // CONFIGURACIÓN DE GOOGLE DRIVE
  // ==========================================================================

  // ID del archivo version.json en Google Drive.
  // Pasos para obtenerlo:
  // 1. Sube tu archivo version.json a Google Drive.
  // 2. Haz clic derecho > Compartir > Copiar enlace.
  // 3. El enlace es algo como: https://drive.google.com/file/d/ESTE_ES_EL_ID/view?usp=sharing
  // 4. Copia solo la parte del ID.
  // 5. Asegúrate de que el acceso sea "Cualquiera con el enlace" (Público).
  final String _driveVersionFileId = '13gJ4dpmFoe8-4ZZ1d_KzYDiV7ZowNaMq';

  // ==========================================================================

  final Dio _dio = Dio(BaseOptions(
    headers: {'User-Agent': 'Saray-App'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  bool _isCheckingUpdate = false;
  bool _isDownloading = false;

  /// Convierte un ID de archivo de Google Drive en una URL de descarga directa
  String _getDriveDownloadUrl(String fileIdOrUrl) {
    String fileId = fileIdOrUrl;

    // Intentar extraer ID de cualquier URL de Drive (incluso si ya es de descarga)
    if (fileIdOrUrl.contains('drive.google.com')) {
      try {
        final uri = Uri.parse(fileIdOrUrl);
        if (uri.queryParameters.containsKey('id')) {
          fileId = uri.queryParameters['id']!;
        } else if (uri.pathSegments.contains('d')) {
          final index = uri.pathSegments.indexOf('d');
          if (index + 1 < uri.pathSegments.length) {
            fileId = uri.pathSegments[index + 1];
          }
        }
      } catch (e) {
        // Si falla el parseo, intentamos usar el string original limpio
      }
    }

    // Limpiar ID de posibles parámetros extra o basura (ej. &uusp, /view, etc)
    if (fileId.contains('&')) {
      fileId = fileId.split('&').first;
    }
    if (fileId.contains('?')) {
      fileId = fileId.split('?').first;
    }
    if (fileId.contains('/')) {
      fileId = fileId.split('/').last;
    }
    
    debugPrint('🔍 UpdateService: ID extraído: $fileId');

    // Retornar URL limpia con confirmación para evitar advertencia de virus
    return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
  }

  /// Verifica si hay una actualización disponible
  Future<UpdateInfo?> checkForUpdate() async {
    if (_isCheckingUpdate) return null;

    try {
      _isCheckingUpdate = true;

      // 1. Obtener versión actual
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint('🔍 UpdateService: Versión actual: ');

      // 2. Obtener información de la última versión desde Drive
      final versionInfo = await _getVersionInfo();
      if (versionInfo == null) {
        debugPrint('❌ UpdateService: No se pudo obtener información de versión');
        return null;
      }

      final latestVersion = versionInfo['version']?.toString() ?? '';
      debugPrint('🔍 UpdateService: Última versión disponible: ');

      // 3. Comparar versiones
      debugPrint('🔍 Comparando versiones: Local [$currentVersion] vs Remota [$latestVersion]');
      if (_isNewerVersion(latestVersion, currentVersion)) {
        debugPrint('✅ UpdateService: ¡Nueva versión detectada!');

        // Obtener URL del APK (puede ser ID o URL)
        String apkSource = versionInfo['apk_url']?.toString() ?? '';
        // Si no hay URL en el JSON, asumimos que no se puede actualizar
        if (apkSource.isEmpty) {
          debugPrint('❌ UpdateService: No se encontró apk_url en version.json');
          return null;
        }

        final apkUrl = _getDriveDownloadUrl(apkSource);

        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          apkUrl: apkUrl,
          releaseNotes: versionInfo['release_notes']?.toString() ?? '',
          releaseDate: DateTime.tryParse(versionInfo['release_date']?.toString() ?? ''),
        );
      }

      debugPrint('ℹ️ UpdateService: La app está actualizada');
      return null;
    } catch (e) {
      debugPrint('❌ UpdateService: Error al verificar actualización: ');
      return null;
    } finally {
      _isCheckingUpdate = false;
    }
  }

  /// Descarga e instala la actualización
  Future<void> downloadAndInstallUpdate(UpdateInfo updateInfo) async {
    if (_isDownloading) {
      debugPrint('⚠️ Ya hay una descarga en progreso');
      return;
    }

    try {
      _isDownloading = true;
      debugPrint('🚀 Iniciando descarga de actualización...');

      // 1. Obtener directorio de descargas privado de la app
      // Usamos getExternalStorageDirectory() que devuelve /storage/emulated/0/Android/data/package/files
      // Esto no requiere permisos de escritura especiales en Android 10+
      final downloadDir = await getExternalStorageDirectory();
      if (downloadDir == null) {
        throw Exception('No se pudo acceder al almacenamiento externo');
      }

      final apkFileName = 'update_v${updateInfo.latestVersion}.apk';
      final apkFile = File(path.join(downloadDir.path, apkFileName));

      // Eliminar archivo anterior si existe para asegurar descarga limpia
      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      debugPrint('⬇️ Descargando APK desde: ${updateInfo.apkUrl}');
      debugPrint('📂 Destino: ${apkFile.path}');

      // 2. Descargar APK
      await _dio.download(
        updateInfo.apkUrl,
        apkFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('⬇️ Progreso: $progress%');
          }
        },
        options: Options(
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      // 3. Verificar descarga
      if (await apkFile.exists()) {
        int fileSize = await apkFile.length();
        debugPrint('✅ Descarga completada. Tamaño: $fileSize bytes');

        // Verificar si es un archivo HTML (error de Drive)
        if (fileSize < 1024 * 1024) { // < 1MB
          bool isHtml = false;
          String content = '';
          
          try {
            content = await apkFile.readAsString();
            if (content.contains('<!DOCTYPE html>') || content.contains('<html')) {
              isHtml = true;
            }
          } catch (e) {
            // Si falla leer como string, quizás es binario
          }

          if (isHtml) {
            debugPrint('⚠️ Detectada página de advertencia de Drive. Intentando extraer enlace de confirmación...');
            
            // Debug: Buscar pistas en el contenido
            final confirmIndex = content.indexOf('confirm=');
            if (confirmIndex != -1) {
               final start = (confirmIndex - 50) < 0 ? 0 : confirmIndex - 50;
               final end = (confirmIndex + 100) > content.length ? content.length : confirmIndex + 100;
               debugPrint('🔍 Pista: encontrado "confirm=" en el texto: ...${content.substring(start, end)}...');
            }

            String? confirmUrl;
            
            // Estrategia Unificada: Buscar cualquier enlace (href o action) que parezca de descarga
            // Captura: href="..." o action="..." que contenga "export=download"
            // Permite rutas relativas (/uc?...) o absolutas (https://drive...)
            final RegExp linkRegex = RegExp(r'(?:href|action)="([^"]*?[?&]export=download[^"]*?)"');
            final Iterable<Match> matches = linkRegex.allMatches(content);
            
            for (final match in matches) {
              String url = match.group(1)!;
              url = url.replaceAll('&amp;', '&');
              
              debugPrint('🔎 Candidato encontrado: $url');

              // Prioridad: Enlace con token de confirmación
              if (url.contains('confirm=')) {
                 if (url.startsWith('http')) {
                   confirmUrl = url;
                 } else {
                   confirmUrl = 'https://drive.google.com$url';
                 }
                 break; // Encontramos el mejor candidato
              }
              
              // Fallback: Si no hay confirm, guardamos el primero que veamos
              if (confirmUrl == null) {
                 if (url.startsWith('http')) {
                   confirmUrl = url;
                 } else {
                   confirmUrl = 'https://drive.google.com$url';
                 }
              }
            }

            // Estrategia Formulario (NUEVA): Parsear <form action="..."> y sus inputs
            // El log mostró que Drive usa un form con action=".../download" y inputs hidden
            if (confirmUrl == null) {
               debugPrint('🔎 Buscando formulario de descarga...');
               // Buscar el form que tenga action
               final RegExp formRegex = RegExp(r'<form[^>]*action="([^"]+)"[^>]*>(.*?)</form>', dotAll: true);
               final formMatch = formRegex.firstMatch(content);
               
               if (formMatch != null) {
                 String actionUrl = formMatch.group(1)!;
                 actionUrl = actionUrl.replaceAll('&amp;', '&');
                 String formBody = formMatch.group(2)!;
                 
                 debugPrint('🔎 Formulario encontrado. Action: $actionUrl');
                 
                 // Extraer inputs hidden
                 final RegExp inputRegex = RegExp(r'name="([^"]+)"\s+value="([^"]+)"');
                 final inputMatches = inputRegex.allMatches(formBody);
                 
                 if (inputMatches.isNotEmpty) {
                   final queryParams = <String>[];
                   for (final m in inputMatches) {
                     final key = m.group(1)!;
                     final value = m.group(2)!;
                     queryParams.add('$key=$value');
                     debugPrint('   + Param: $key = $value');
                   }
                   
                   final separator = actionUrl.contains('?') ? '&' : '?';
                   confirmUrl = '$actionUrl$separator${queryParams.join('&')}';
                 }
               }
            }
            
            // Estrategia de Respaldo: Buscar token confirm=XXXX en cualquier parte del texto
            if (confirmUrl == null) {
               final RegExp tokenRegex = RegExp(r'confirm=([a-zA-Z0-9_-]+)');
               final tokenMatch = tokenRegex.firstMatch(content);
               if (tokenMatch != null) {
                 final token = tokenMatch.group(1)!;
                 debugPrint('🔎 Token encontrado en texto plano: $token');
                 
                 String fileId = '';
                 final uri = Uri.parse(updateInfo.apkUrl);
                 if (uri.queryParameters.containsKey('id')) {
                   fileId = uri.queryParameters['id']!;
                 }
                 
                 if (fileId.isNotEmpty) {
                   confirmUrl = 'https://drive.google.com/uc?export=download&id=$fileId&confirm=$token';
                 }
               }
            }
            
            if (confirmUrl != null) {
              debugPrint('🔄 Reintentando descarga con token de confirmación: $confirmUrl');
              
              // Reintentar descarga
              int lastProgress = -1;
              await _dio.download(
                confirmUrl,
                apkFile.path,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    final progress = (received / total * 100).toInt();
                    // Solo imprimir cada 10% para no saturar el log
                    if (progress != lastProgress && (progress % 10 == 0 || progress == 100)) {
                        debugPrint('⬇️ Progreso (Reintento): $progress%');
                        lastProgress = progress;
                    }
                  }
                },
              );
              
              fileSize = await apkFile.length();
              debugPrint('✅ Segunda descarga completada. Tamaño: $fileSize bytes');
              
              // Verificar de nuevo si sigue siendo HTML (caso de error persistente)
              if (fileSize < 1024 * 1024) {
                 try {
                    final newContent = await apkFile.readAsString();
                    if (newContent.contains('<!DOCTYPE html>') || newContent.contains('<html')) {
                       throw Exception('Error persistente: Google Drive sigue devolviendo una página HTML.');
                    }
                 } catch (_) {}
              }
            } else {
              debugPrint('❌ ERROR: El archivo descargado es una página HTML y no se encontró enlace de confirmación.');
              
              // Intentar imprimir el body o una sección central para mejor depuración
              int startBody = content.indexOf('<body');
              if (startBody == -1) startBody = 0;
              int printLen = 2000;
              String debugContent = content.substring(startBody, (startBody + printLen) > content.length ? content.length : startBody + printLen);
              debugPrint('📄 Contenido (desde body): $debugContent...');
              
              throw Exception('El archivo descargado no es un APK válido (es HTML).');
            }
          } else {
             debugPrint('⚠️ ADVERTENCIA: El archivo parece muy pequeño ($fileSize bytes) pero no es HTML texto plano.');
          }
        }

        // 4. Instalar APK
        await _installApk(apkFile);
      } else {
        throw Exception('El archivo descargado no aparece en el sistema de archivos');
      }
    } catch (e) {
      debugPrint('❌ Error en proceso de actualización: $e');
      rethrow;
    } finally {
      _isDownloading = false;
    }
  }

  /// Lanza el intent de instalación
  Future<void> _installApk(File apkFile) async {
    if (!Platform.isAndroid) return;

    try {
      debugPrint('📦 Preparando instalación...');

      // Verificar permiso REQUEST_INSTALL_PACKAGES
      if (!await Permission.requestInstallPackages.isGranted) {
        debugPrint('🔐 Solicitando permiso de instalación de paquetes...');
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          throw Exception('Permiso de instalación denegado por el usuario');
        }
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;

      // Construir URI usando FileProvider
      // Hemos configurado <external-files-path name='app_files' path='.' /> en file_paths.xml
      // Esto mapea a getExternalStorageDirectory() (Android/data/package/files)
      // Por lo tanto, la URI es: content://package.fileprovider/app_files/nombre_archivo.apk

      final fileName = path.basename(apkFile.path);
      final contentUri = 'content://$packageName.fileprovider/app_files/$fileName';

      debugPrint('🔗 URI de instalación: $contentUri');

      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: contentUri,
        type: 'application/vnd.android.package-archive',
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_GRANT_READ_URI_PERMISSION, // Crucial para que el instalador pueda leer el archivo
        ],
      );

      debugPrint('🚀 Lanzando instalador...');
      await intent.launch();
    } catch (e) {
      debugPrint('❌ Error al intentar instalar: $e');
      throw Exception('Error al iniciar la instalación: $e');
    }
  }

  /// Obtiene el JSON de versión desde Drive
  Future<Map<String, dynamic>?> _getVersionInfo() async {
    try {
      if (_driveVersionFileId == 'TU_ID_DEL_ARCHIVO_VERSION_JSON_AQUI') {
        debugPrint('⚠️ UpdateService: ID de archivo de versión no configurado.');
        return null;
      }

      final url = _getDriveDownloadUrl(_driveVersionFileId);
      debugPrint('🌐 Obteniendo info de versión desde: ');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (response.data is Map) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          return json.decode(response.data) as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error obteniendo versión: ');
      // Fallback a assets para desarrollo/pruebas
      try {
        final content = await rootBundle.loadString('version.json');
        return json.decode(content) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
  }

  /// Compara versiones semánticas (x.y.z)
  bool _isNewerVersion(String latestVersion, String currentVersion) {
    try {
      final latestParts = latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      // Normalizar longitudes
      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error comparando versiones: ');
      return false;
    }
  }
}
