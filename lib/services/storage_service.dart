import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen de producto
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      // Validar que el archivo existe
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      // Validar que el productId no esté vacío
      if (productId.isEmpty) {
        throw Exception('ID de producto inválido');
      }

      // Verificar que el usuario esté autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileExtension = path.extension(imageFile.path);
      String baseName = path.basenameWithoutExtension(imageFile.path);
      String fileName = '${productId}_${timestamp}_$baseName$fileExtension';

      // Validar que el nombre del archivo no esté vacío
      if (fileName.isEmpty ||
          fileName == '${productId}_${timestamp}_$fileExtension') {
        fileName = '${productId}_${timestamp}_image$fileExtension';
      }

      debugPrint('Subiendo imagen: $fileName a ruta: products/$fileName');

      Reference ref = _storage.ref().child('products/$fileName');

      debugPrint('Referencia creada: ${ref.fullPath}');
      debugPrint('Bucket: ${ref.bucket}');

      UploadTask uploadTask = ref.putFile(imageFile);
      debugPrint('UploadTask creado, esperando completación...');

      TaskSnapshot snapshot = await uploadTask;

      debugPrint('UploadTask completado con estado: ${snapshot.state}');
      debugPrint('Bytes transferidos: ${snapshot.bytesTransferred}');
      debugPrint('Total bytes: ${snapshot.totalBytes}');

      // Verificar que la subida fue exitosa
      if (snapshot.state != TaskState.success) {
        throw Exception(
          'La subida de la imagen falló con estado: ${snapshot.state}',
        );
      }

      debugPrint('Imagen subida exitosamente, obteniendo URL...');

      String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('URL obtenida exitosamente: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Error detallado al subir imagen: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Subir múltiples imágenes de producto
  Future<List<String>> uploadProductImages(
    List<File> imageFiles,
    String productId,
  ) async {
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
