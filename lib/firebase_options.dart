import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // We use the same configuration for simplicity in the hackathon.
    return const FirebaseOptions(
      apiKey: 'AIzaSyDJO20HmtrtV_n3y726hql7WNagk0NDHAc',
      appId: '1:809964592173:web:b6eab7b55812027589eca4', // Web app ID fallback
      messagingSenderId: '809964592173',
      projectId: 'hackaton-16e9a',
      storageBucket: 'hackaton-16e9a.firebasestorage.app',
    );
  }
}
