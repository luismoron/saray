import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "your-api-key",  // Reemplaza con el valor de Firebase Console
      authDomain: "bazar-838fa.firebaseapp.com",
      projectId: "bazar-838fa",
      storageBucket: "bazar-838fa.appspot.com",
      messagingSenderId: "your-messaging-sender-id",  // Reemplaza
      appId: "your-app-id",  // Reemplaza
    );
  }
}