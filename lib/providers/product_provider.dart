import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '';

  // Getters
  List<Product> get products => _filteredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Constructor
  ProductProvider() {
    loadProducts();
    loadCategories();
  }

  // Cargar todos los productos
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _productService.getProducts().listen((products) {
        _products = products;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar categorías
  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // Buscar productos
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filtrar por categoría
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _applyFilters();
  }

  // Aplicar filtros
  void _applyFilters() {
    List<Product> filtered = _products;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filtrar por categoría
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    _filteredProducts = filtered;
    notifyListeners();
  }

  // Obtener producto por ID
  Future<Product?> getProductById(String productId) async {
    return await _productService.getProductById(productId);
  }

  // Agregar producto (para admins)
  Future<String?> addProduct(Product product) async {
    final productId = await _productService.addProduct(product);
    if (productId != null) {
      loadProducts(); // Recargar productos
    }
    return productId;
  }

  // Actualizar producto (para admins)
  Future<bool> updateProduct(String productId, Product product) async {
    final success = await _productService.updateProduct(productId, product);
    if (success) {
      loadProducts(); // Recargar productos
    }
    return success;
  }

  // Eliminar producto (para admins)
  Future<bool> deleteProduct(String productId) async {
    final success = await _productService.deleteProduct(productId);
    if (success) {
      loadProducts(); // Recargar productos
    }
    return success;
  }
}
