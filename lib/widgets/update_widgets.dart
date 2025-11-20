import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/update_provider.dart';

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
                      await updateProvider.downloadUpdate();
                      if (context.mounted) {
                        if (updateProvider.lastErrorMessage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Descargando e instalando actualización...'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          // Mostrar mensaje de error específico
                          final errorMessage = updateProvider.lastErrorMessage!;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                child: updateProvider.isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Instalar'),
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
                    await updateProvider.downloadUpdate();
                    if (context.mounted) {
                      if (updateProvider.lastErrorMessage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Descargando e instalando actualización...'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else {
                        // Mostrar mensaje de error específico
                        final errorMessage = updateProvider.lastErrorMessage!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
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
