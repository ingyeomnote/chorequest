/// Environment configuration for ChoreQuest
///
/// Manages different environments (development, staging, production)
/// and provides environment-specific configuration values.
library;

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _current = Environment.production;

  /// Current environment
  static Environment get current => _current;

  /// Set current environment
  static void setCurrent(Environment env) {
    _current = env;
  }

  /// Initialize environment from command line
  /// Usage: flutter run --dart-define=ENVIRONMENT=production
  static void initFromDefine() {
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    switch (envString.toLowerCase()) {
      case 'production':
        _current = Environment.production;
        break;
      case 'staging':
        _current = Environment.staging;
        break;
      default:
        _current = Environment.development;
    }
  }

  /// API base URL
  static String get apiUrl {
    switch (_current) {
      case Environment.development:
        return 'http://localhost:5001/chorequest-dev/us-central1';
      case Environment.staging:
        return 'https://us-central1-chorequest-staging.cloudfunctions.net';
      case Environment.production:
        return 'https://us-central1-chorequest-prod.cloudfunctions.net';
    }
  }

  /// Firebase project ID
  static String get projectId {
    switch (_current) {
      case Environment.development:
        return 'chorequest-dev';
      case Environment.staging:
        return 'chorequest-staging';
      case Environment.production:
        return 'chorequest-prod';
    }
  }

  /// Enable Firebase Emulator (for local development)
  static bool get useEmulator => _current == Environment.development;

  /// Emulator host
  static String get emulatorHost => 'localhost';

  /// Firestore emulator port
  static int get firestoreEmulatorPort => 8080;

  /// Auth emulator port
  static int get authEmulatorPort => 9099;

  /// Storage emulator port
  static int get storageEmulatorPort => 9199;

  /// Enable debug logging
  static bool get enableDebugLog => _current != Environment.production;

  /// Enable analytics
  static bool get enableAnalytics => _current == Environment.production;

  /// App name with environment suffix
  static String get appName {
    switch (_current) {
      case Environment.development:
        return 'ChoreQuest (Dev)';
      case Environment.staging:
        return 'ChoreQuest (Staging)';
      case Environment.production:
        return 'ChoreQuest';
    }
  }

  /// Is development environment
  static bool get isDevelopment => _current == Environment.development;

  /// Is staging environment
  static bool get isStaging => _current == Environment.staging;

  /// Is production environment
  static bool get isProduction => _current == Environment.production;
}
