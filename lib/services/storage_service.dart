import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen de producto
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      Reference ref = _storage.ref().child('products/$productId/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Subir múltiples imágenes de producto
  Future<List<String>> uploadProductImages(List<File> imageFiles, String productId) async {
    List<String> urls = [];
    for (File imageFile in imageFiles) {
      String url = await uploadProductImage(imageFile, productId);
      urls.add(url);
    }
    return urls;
  }

  // Eliminar imagen
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  // Obtener referencia de storage
  Reference getStorageRef(String path) {
    return _storage.ref().child(path);
  }
}