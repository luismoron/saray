import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/sample_data_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${l10n.welcome}, ${authProvider.user?.name ?? 'User'}!'),
            const SizedBox(height: 20),
            const Text('This is the home screen of Bazar de Saray.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/catalog');
              },
              child: Text(l10n.viewProducts),
            ),
            const SizedBox(height: 20),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/cart');
                  },
                  icon: Badge.count(
                    count: cartProvider.itemCount,
                    isLabelVisible: cartProvider.itemCount > 0,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: const Text('Ver Carrito'),
                );
              },
            ),
            const SizedBox(height: 20),
            // Botón temporal para agregar datos de ejemplo
            ElevatedButton(
              onPressed: () async {
                final sampleDataService = SampleDataService();
                try {
                  await sampleDataService.addSampleProducts();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Datos de ejemplo agregados exitosamente'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error agregando datos: $e'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: const Text('Agregar Productos de Ejemplo'),
            ),
          ],
        ),
      ),
    );
  }
}