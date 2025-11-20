import 'package:flutter/material.dart';
import '../services/update_service.dart';

/// Provider para manejar el estado de las actualizaciones
class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService = UpdateService();
  UpdateInfo? _updateInfo;
  bool _isChecking = false;
  bool _isDownloading = false;
  String? _lastErrorMessage;

  UpdateInfo? get updateInfo => _updateInfo;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  String? get lastErrorMessage => _lastErrorMessage;

  /// Verifica si hay actualizaciones disponibles
  Future<void> checkForUpdates() async {
    debugPrint('🔍 UpdateProvider: Iniciando verificación de actualizaciones...');
    _isChecking = true;
    notifyListeners();

    try {
      _updateInfo = await _updateService.checkForUpdate();
      debugPrint('🔍 UpdateProvider: Resultado de checkForUpdate: $_updateInfo');
      if (_updateInfo != null) {
        debugPrint('✅ UpdateProvider: ¡Actualización disponible! Versión: ${_updateInfo!.latestVersion}');
      } else {
        debugPrint('ℹ️ UpdateProvider: No hay actualizaciones disponibles');
      }
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Descarga e instala automáticamente el APK
  Future<void> downloadUpdate() async {
    if (_updateInfo == null) return;

    _isDownloading = true;
    _lastErrorMessage = null; // Limpiar error anterior
    notifyListeners();

    try {
      await _updateService.downloadAndInstallUpdate(_updateInfo!);
    } catch (e) {
      debugPrint('❌ UpdateProvider: Excepción durante descarga: $e');
      // Guardar el mensaje de error para mostrarlo en la UI
      _lastErrorMessage = e.toString();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Limpia la información de actualización
  void clearUpdateInfo() {
    _updateInfo = null;
    notifyListeners();
  }
}
