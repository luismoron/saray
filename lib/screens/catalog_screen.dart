import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalog),
      ),
      body: Center(
        child: const Text('Aquí irá la lista de productos.'),
      ),
    );
  }
}