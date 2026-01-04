import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBWB3-TydN5_sN_zuj-fAzrv2NQTlWPirA",
      appId: "1:120560352418:android:63864f1301928d17ffabfb",
      messagingSenderId: "120560352418",
      projectId: "cuoikidienthoai",
      databaseURL: "https://cuoikidienthoai-default-rtdb.firebaseio.com",
      storageBucket: "cuoikidienthoai.firebasestorage.app",
    );
  }
}
