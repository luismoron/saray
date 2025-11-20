import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saray/services/update_service.dart';

/// Provider para manejar el estado de las actualizaciones
class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService = UpdateService();
  UpdateInfo? _updateInfo;
  bool _isChecking = false;
  bool _isDownloading = false;

  UpdateInfo? get updateInfo => _updateInfo;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;

  /// Verifica si hay actualizaciones disponibles
  Future<void> checkForUpdates() async {
    _isChecking = true;
    notifyListeners();

    try {
      _updateInfo = await _updateService.checkForUpdate();
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Descarga el APK y devuelve la ruta del archivo descargado
  Future<String?> downloadAndInstallUpdate() async {
    if (_updateInfo == null) return null;

    _isDownloading = true;
    notifyListeners();

    try {
      final apkPath = await _updateService.downloadAndInstallUpdate(_updateInfo!);
      if (apkPath != null) {
        // Actualizar la información con la ruta del APK descargado
        _updateInfo = UpdateInfo(
          currentVersion: _updateInfo!.currentVersion,
          latestVersion: _updateInfo!.latestVersion,
          apkUrl: _updateInfo!.apkUrl,
          releaseNotes: _updateInfo!.releaseNotes,
          releaseDate: _updateInfo!.releaseDate,
          downloadedApkPath: apkPath,
        );
      }
      return apkPath;
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

/// Widget para mostrar notificaciones de actualización
class UpdateNotificationBanner extends StatelessWidget {
  const UpdateNotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        final updateInfo = updateProvider.updateInfo;

        if (updateInfo == null) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.system_update,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva versión disponible: ${updateInfo.latestVersion}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      updateInfo.releaseNotes,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: updateProvider.isDownloading
                  ? null
                  : () async {
                      final apkPath = await updateProvider.downloadAndInstallUpdate();
                      if (apkPath != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('APK descargado. Instalador abierto automáticamente.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                child: updateProvider.isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Actualizar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Diálogo detallado de actualización
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        final updateInfo = updateProvider.updateInfo;

        if (updateInfo == null) return const SizedBox.shrink();

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.system_update,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Actualización Disponible'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versión ${updateInfo.latestVersion}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (updateInfo.releaseDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fecha de lanzamiento: ${_formatDate(updateInfo.releaseDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Novedades:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(updateInfo.releaseNotes),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Después'),
            ),
            ElevatedButton(
              onPressed: updateProvider.isDownloading
                ? null
                : () async {
                    Navigator.of(context).pop();
                    final apkPath = await updateProvider.downloadAndInstallUpdate();
                    if (apkPath != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('APK descargado. Instalador abierto automáticamente.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
              child: updateProvider.isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Instalar Actualización'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

/// Ejemplo de integración en la pantalla principal
class UpdateHomeScreenExample extends StatefulWidget {
  const UpdateHomeScreenExample({super.key});

  @override
  State<UpdateHomeScreenExample> createState() => _UpdateHomeScreenExampleState();
}

class _UpdateHomeScreenExampleState extends State<UpdateHomeScreenExample> {
  @override
  void initState() {
    super.initState();
    // Verificar actualizaciones al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdateProvider>().checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saray App'),
        actions: [
          // Botón para verificar actualizaciones manualmente
          Consumer<UpdateProvider>(
            builder: (context, updateProvider, child) {
              return IconButton(
                onPressed: updateProvider.isChecking
                  ? null
                  : () => updateProvider.checkForUpdates(),
                icon: updateProvider.isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
                tooltip: 'Verificar actualizaciones',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de notificación de actualización
          const UpdateNotificationBanner(),

          // Contenido principal de la app
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¡Bienvenido a Saray!'),
                  const SizedBox(height: 20),

                  // Botón para mostrar diálogo de actualización si hay una disponible
                  Consumer<UpdateProvider>(
                    builder: (context, updateProvider, child) {
                      if (updateProvider.updateInfo == null) {
                        return const SizedBox.shrink();
                      }

                      return ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const UpdateDialog(),
                        ),
                        child: const Text('Ver Detalles de Actualización'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}