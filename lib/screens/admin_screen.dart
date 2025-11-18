import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Productos'),
            Tab(text: 'Solicitudes'),
            Tab(text: 'Usuarios'),
          ],
          labelColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
          unselectedLabelColor: (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white).withOpacity(0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildRequestsTab(),
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Agregar Producto',
            )
          : null,
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay usuarios registrados'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            final userId = userDoc.id;
            final name = userData['name'] ?? 'Sin nombre';
            final email = userData['email'] ?? 'Sin email';
            final role = userData['role'] ?? 'buyer';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    Text(
                      'Rol: ${_getRoleDisplayName(role)}',
                      style: TextStyle(
                        color: _getRoleColor(role),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _changeUserRole(context, userId, value, name),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'buyer',
                      child: Text('Comprador'),
                    ),
                    const PopupMenuItem(
                      value: 'seller',
                      child: Text('Vendedor'),
                    ),
                    const PopupMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.products.isEmpty) {
          return const Center(
            child: Text('No hay productos disponibles'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return Card(
              child: ListTile(
                leading: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditProductDialog(context, product),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteProduct(context, product),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    // Placeholder - implementar solicitudes de vendedor
    return const Center(
      child: Text('Funcionalidad de solicitudes próximamente'),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado'), duration: Duration(seconds: 2)),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar producto'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'buyer':
        return 'Comprador';
      case 'seller':
        return 'Vendedor';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'buyer':
        return Colors.blue;
      case 'seller':
        return Colors.green;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _changeUserRole(BuildContext context, String userId, String newRole, String userName) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'role': newRole});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol de $userName cambiado a ${_getRoleDisplayName(newRole)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar rol: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _categoryController.text = widget.product!.category;
      _existingImageUrls = List.from(widget.product!.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Producto' : 'Agregar Producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Precio
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  final price = double.tryParse(value!);
                  if (price == null || price <= 0) return 'Precio inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stock
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  final stock = int.tryParse(value!);
                  if (stock == null || stock < 0) return 'Stock inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoría
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Imágenes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Imágenes:'),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.image),
                        label: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Mostrar imágenes existentes
                  if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingImageUrls.length + _selectedImages.length,
                        itemBuilder: (context, index) {
                          if (index < _existingImageUrls.length) {
                            // Imagen existente
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  Image.network(
                                    _existingImageUrls[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, size: 80),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeExistingImage(index),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Nueva imagen seleccionada
                            final newImageIndex = index - _existingImageUrls.length;
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _selectedImages[newImageIndex],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeNewImage(newImageIndex),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Actualizar' : 'Agregar'),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final storageService = StorageService();

      // Combinar imágenes existentes con nuevas
      List<String> imageUrls = List.from(_existingImageUrls); // Mantener imágenes existentes no eliminadas

      bool success;
      String finalProductId;

      if (widget.product != null) {
        // Producto existente - subir imágenes con ID existente
        finalProductId = widget.product!.id;

        // Subir nuevas imágenes si hay
        if (_selectedImages.isNotEmpty) {
          final uploadedUrls = await storageService.uploadProductImages(
            _selectedImages,
            finalProductId,
          );
          imageUrls.addAll(uploadedUrls); // Agregar nuevas imágenes al final
        }

        final product = Product(
          id: finalProductId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _categoryController.text,
          stock: int.parse(_stockController.text),
          imageUrls: imageUrls,
          createdAt: widget.product!.createdAt,
          updatedAt: DateTime.now(),
        );

        success = await productProvider.updateProduct(finalProductId, product);
      } else {
        // Producto nuevo - guardar primero para obtener ID real, luego subir imágenes
        final tempProduct = Product(
          id: '', // ID vacío para nuevo producto
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _categoryController.text,
          stock: int.parse(_stockController.text),
          imageUrls: [], // URLs vacías inicialmente
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Guardar producto para obtener ID real
        final productId = await productProvider.addProduct(tempProduct);
        if (productId == null) {
          throw Exception('Error al crear producto');
        }

        finalProductId = productId;

        // Subir imágenes con ID real
        if (_selectedImages.isNotEmpty) {
          final uploadedUrls = await storageService.uploadProductImages(
            _selectedImages,
            finalProductId,
          );
          imageUrls.addAll(uploadedUrls);
        }

        // Actualizar producto con URLs de imágenes
        final finalProduct = Product(
          id: finalProductId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _categoryController.text,
          stock: int.parse(_stockController.text),
          imageUrls: imageUrls,
          createdAt: tempProduct.createdAt,
          updatedAt: DateTime.now(),
        );

        success = await productProvider.updateProduct(finalProductId, finalProduct);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null
                ? 'Producto actualizado'
                : 'Producto agregado'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar producto'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}