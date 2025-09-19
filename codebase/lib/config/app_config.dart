/// App configuration class for API keys and settings
class AppConfig {
  // Set your Gemini API key here for testing
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyBdQ5cHwQCUaTvr8qywxBxEHFyT1rETWYQ'; // Add your API key here

  // Alternative: set via environment variable at compile time
  static const String envGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );

  /// Gets the API key, preferring environment variable over hardcoded
  static String get activeGeminiApiKey {
    if (envGeminiApiKey.isNotEmpty) {
      return envGeminiApiKey;
    }
    return geminiApiKey;
  }

  /// Check if API key is configured
  static bool get hasGeminiApiKey {
    return activeGeminiApiKey.isNotEmpty;
  }
}
