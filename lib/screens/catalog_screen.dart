import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalog),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: _buildSearchAndFilters(context, l10n, theme),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los productos aparecerán aquí cuando estén disponibles',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return ProductCard(
                product: product,
                onTap: () => _showProductDetails(context, product),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            productProvider.searchProducts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                onChanged: (value) {
                  productProvider.searchProducts(value);
                },
              ),

              const SizedBox(height: 12),

              // Filtros por categoría
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Opción "Todos"
                    FilterChip(
                      label: Text(l10n.allCategories),
                      selected: _selectedCategory.isEmpty,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = '';
                        });
                        productProvider.filterByCategory('');
                      },
                    ),

                    const SizedBox(width: 8),

                    // Categorías disponibles
                    ...productProvider.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : '';
                            });
                            productProvider.filterByCategory(selected ? category : '');
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Información de resultados
              Row(
                children: [
                  Text(
                    '${productProvider.products.length} ${l10n.productsFound}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (productProvider.searchQuery.isNotEmpty ||
                      productProvider.selectedCategory.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _selectedCategory = '';
                        });
                        productProvider.clearFilters();
                      },
                      icon: const Icon(Icons.clear),
                      label: Text(l10n.clearFilters),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, product) {
    // TODO: Implementar pantalla de detalles del producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de ${product.name} - Próximamente'),
      ),
    );
  }
}