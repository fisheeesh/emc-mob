class EUrls {
  /// ANDROID
  static const String AUTHORIZATION_ENDPOINT_ANDROID =
      'https://10.0.2.2:8443/security/auth';
  static const String LOGIN_ENDPOINT_ANDROID =
      'https://10.0.2.2:8443/security/login';
  static const String REFRESH_ENDPOINT_ANDROID =
      'https://10.0.2.2:8443/security/refresh';
  static const String HISTORY_ENDPOINT_ANDROID =
      'https://10.0.2.2:8443/mobile/checkins';
  static const String CHECK_IN_ENDPOINT_ANDROID =
      'https://10.0.2.2:8443/mobile/checkin';

  /// IOS
  static const String AUTHORIZATION_ENDPOINT_IOS =
      'https://192.168.1.185:8443/security/auth';
  static const String LOGIN_ENDPOINT_IOS =
      'https://192.168.1.185:8443/security/login';
  static const String REFRESH_ENDPOINT_IOS =
      'https://192.168.1.185:8443/security/refresh';
  static const String HISTORY_ENDPOINT_IOS =
      'https://192.168.1.185:8443/mobile/checkins';
  static const String CHECK_IN_ENDPOINT_IOS =
      'https://192.168.1.185:8443/mobile/checkin';

  /// HTTP method
  static const String GET = "GET";
  static const String POST = "POST";

  /// JWT
  static const BEARER = "Bearer ";
}
