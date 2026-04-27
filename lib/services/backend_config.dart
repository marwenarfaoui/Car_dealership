class BackendConfig {
  BackendConfig._();

  /// Pass with: --dart-define=API_BASE_URL=https://your-api.example.com
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static bool get isEnabled => apiBaseUrl.trim().isNotEmpty;
}
