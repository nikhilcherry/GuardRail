import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the Guardrail app.
/// 
/// This class handles Firebase initialization with the project credentials.
/// The configuration values match the google-services.json file.
class FirebaseConfig {
  // Firebase project configuration
  static const String projectId = 'guardrail-79bcd';
  static const String storageBucket = 'guardrail-79bcd.firebasestorage.app';
  static const String messagingSenderId = '342366342068';
  static const String appId = '1:342366342068:android:4906a9b9a3e003289040e1';
  static const String apiKey = 'AIzaSyD3292KcuOK5cSr23yRyVMBm9dZdaLCjkQ';

  /// Initialize Firebase with platform-specific options.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
        ),
      );
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  /// Check if Firebase is already initialized
  static bool get isInitialized {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }
}
