/// Firebase configuration and initialization
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'environment.dart';
import '../utils/logger.dart';
import '../firebase_options.dart';

/// Firebase configuration class
class FirebaseConfig {
  static final _log = Log.get('FirebaseConfig');
  /// Initialize Firebase
  ///
  /// This method should be called in main() before runApp()
  static Future<void> initialize() async {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firebase Emulator for local development
    // DISABLED: Not using emulator in this environment
    // if (EnvironmentConfig.useEmulator) {
    //   await _configureEmulator();
    // }

    // Configure Firestore settings
    _configureFirestore();
    
    _log.info('Firebase initialized successfully');
  }

  /// Configure Firebase Emulator
  static Future<void> _configureEmulator() async {
    final host = EnvironmentConfig.emulatorHost;

    // Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      EnvironmentConfig.firestoreEmulatorPort,
    );

    // Auth Emulator
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      EnvironmentConfig.authEmulatorPort,
    );

    // Storage Emulator
    await FirebaseStorage.instance.useStorageEmulator(
      host,
      EnvironmentConfig.storageEmulatorPort,
    );

    _log.info('Firebase Emulator enabled');
    _log.info('  Firestore: $host:${EnvironmentConfig.firestoreEmulatorPort}');
    _log.info('  Auth: $host:${EnvironmentConfig.authEmulatorPort}');
    _log.info('  Storage: $host:${EnvironmentConfig.storageEmulatorPort}');
  }

  /// Configure Firestore settings
  static void _configureFirestore() {
    final settings = Settings(
      persistenceEnabled: true, // Enable offline persistence
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    FirebaseFirestore.instance.settings = settings;

    _log.info('Firestore configured with offline persistence');
  }

  /// Get Firebase project info
  static Map<String, dynamic> getProjectInfo() {
    return {
      'environment': EnvironmentConfig.current.name,
      'projectId': EnvironmentConfig.projectId,
      'useEmulator': EnvironmentConfig.useEmulator,
      'appName': EnvironmentConfig.appName,
    };
  }
}
