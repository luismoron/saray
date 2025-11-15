import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSampleProducts() async {
    final products = [
      {
        'name': 'Lavadora Samsung 8kg',
        'description': 'Lavadora automática con 8kg de capacidad, centrifugado 1200 RPM, múltiples programas de lavado.',
        'price': 899.99,
        'category': 'Electrodomésticos',
        'stock': 5,
        'imageUrls': ['https://example.com/lavadora-samsung.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Refrigerador LG 300L',
        'description': 'Refrigerador frost free de 300 litros, dispensador de agua, control de temperatura digital.',
        'price': 1299.99,
        'category': 'Electrodomésticos',
        'stock': 3,
        'imageUrls': ['https://example.com/refrigerador-lg.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Microondas Panasonic 25L',
        'description': 'Microondas digital de 25 litros con grill, 1000W de potencia, múltiples funciones.',
        'price': 199.99,
        'category': 'Electrodomésticos',
        'stock': 8,
        'imageUrls': ['https://example.com/microondas-panasonic.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Repuesto Motor Lavadora',
        'description': 'Motor completo para lavadora Samsung modelo WA80H4000SW, incluye polea y cojinetes.',
        'price': 89.99,
        'category': 'Repuestos',
        'stock': 12,
        'imageUrls': ['https://example.com/motor-lavadora.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Bomba de Agua Lavadora',
        'description': 'Bomba de drenaje universal compatible con la mayoría de modelos de lavadora.',
        'price': 45.99,
        'category': 'Repuestos',
        'stock': 20,
        'imageUrls': ['https://example.com/bomba-agua.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Termostato Refrigerador',
        'description': 'Termostato digital para refrigeradores LG, controla la temperatura del congelador.',
        'price': 29.99,
        'category': 'Repuestos',
        'stock': 15,
        'imageUrls': ['https://example.com/termostato-refri.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Placa de Calentamiento Microondas',
        'description': 'Placa magnética de calentamiento para microondas Panasonic, 700W.',
        'price': 79.99,
        'category': 'Repuestos',
        'stock': 6,
        'imageUrls': ['https://example.com/placa-microondas.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Aspiradora Robot Xiaomi',
        'description': 'Aspiradora robot inteligente con navegación láser, app control, 2500Pa de succión.',
        'price': 349.99,
        'category': 'Electrodomésticos',
        'stock': 4,
        'imageUrls': ['https://example.com/aspiradora-xiaomi.jpg'],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    for (final productData in products) {
      try {
        await _firestore.collection('products').add(productData);
        print('Producto agregado: ${productData['name']}');
      } catch (e) {
        print('Error agregando producto ${productData['name']}: $e');
      }
    }

    print('Datos de ejemplo agregados exitosamente');
  }
}