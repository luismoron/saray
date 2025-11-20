import 'package:flutter/material.dart';
import '../services/update_service.dart';

class UpdateTestScreen extends StatefulWidget {
  const UpdateTestScreen({super.key});

  @override
  State<UpdateTestScreen> createState() => _UpdateTestScreenState();
}

class _UpdateTestScreenState extends State<UpdateTestScreen> {
  String _testResults = 'Presiona el botón para ejecutar pruebas';
  final UpdateService _updateService = UpdateService();

  Future<void> _runTests() async {
    setState(() {
      _testResults = 'Ejecutando verificación de actualización...\n';
    });

    try {
      final info = await _updateService.checkForUpdate();

      setState(() {
        if (info != null) {
          _testResults += '\n✅ Actualización encontrada:\n'
              'Versión: ${info.latestVersion}\n'
              'Notas: ${info.releaseNotes}\n'
              'URL: ${info.apkUrl}';
        } else {
          _testResults += '\n✅ Verificación completada. No hay actualizaciones pendientes.';
        }
      });
    } catch (e) {
      setState(() {
        _testResults += '\n❌ Error durante las pruebas: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pruebas de Actualización'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _runTests,
              child: const Text('Ejecutar Pruebas del Sistema'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Resultados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _testResults,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '💡 Revisa los logs en la consola de desarrollo para más detalles.',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}