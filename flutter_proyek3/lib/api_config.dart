class ApiConfig {
  // ignore: constant_identifier_names
  static const String BASE_URL = 'https://agrosquad.up.railway.app/api/';
  static const String baseUrl = BASE_URL;
  static const String storageUrl = 'https://agrosquad.up.railway.app/uploads/';

  /// Generates a [Uri] safely by combining the base URL with the given [path].
  /// It prevents double slashes ('//') by trimming trailing/leading slashes.
  static Uri getUri(String path) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    var cleanPath = path.trim();
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return Uri.parse('$cleanBase/$cleanPath');
  }

  /// Generates a full storage URL string safely by combining the storage base URL
  /// with the given [path]. Handles backslashes, leading slashes, full URLs,
  /// and common Laravel/public directory prefixes dynamically.
  static String getStorageUrl(String path) {
    var cleanPath = path.replaceAll('\\', '/').trim();

    // If path is already a full URL, return it as is
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    // Strip leading slash first
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // Strip common prefixes to prevent duplication
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring('public/'.length);
    }

    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    if (cleanPath.startsWith('uploads/')) {
      cleanPath = cleanPath.substring('uploads/'.length);
    }

    if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.substring('storage/'.length);
    }

    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final cleanStorage = storageUrl.endsWith('/')
        ? storageUrl.substring(0, storageUrl.length - 1)
        : storageUrl;

    return '$cleanStorage/$cleanPath';
  }
}
