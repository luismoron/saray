import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/update_widgets.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar actualizaciones automáticamente al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdateProvider>().checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Botón de descarga que solo aparece cuando hay actualización disponible
          Consumer<UpdateProvider>(
            builder: (context, updateProvider, child) {
              // Solo mostrar el botón si hay una actualización disponible
              if (updateProvider.updateInfo == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const UpdateDialog(),
                ),
                icon: const Icon(Icons.download),
                tooltip: 'Descargar actualización ${updateProvider.updateInfo!.latestVersion}',
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/cart');
                    },
                  ),
                  if (cartProvider.hasItems)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
      body: Column(
        children: [
          // Banner de notificación de actualización
          const UpdateNotificationBanner(),

          // Contenido principal
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${l10n.welcome}, ${authProvider.user?.name ?? 'User'}!'),
                  const SizedBox(height: 20),
                  const Text('This is the home screen of Saray.'),
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