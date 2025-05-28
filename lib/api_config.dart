import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String androidBaseUrl =
      'http://192.168.10.157:8080/api/products'; // Include port!
  static const String webBaseUrl = 'http://localhost:8080/api/products';

  static String getBaseUrl() {
    return kIsWeb ? webBaseUrl : androidBaseUrl;
  }
}
