import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the registered ShowShelf Android application.
/// iOS and other platforms are intentionally deferred.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'ShowShelf Firebase is not configured for web yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'ShowShelf Firebase is currently configured for Android only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEdUBcdPr-tZkHVAWkoNK5sD01KA0L6D4',
    appId: '1:905009635182:android:983ee9a39d629a572c6b7f',
    messagingSenderId: '905009635182',
    projectId: 'showshelf-a6ad0',
    storageBucket: 'showshelf-a6ad0.firebasestorage.app',
  );
}
