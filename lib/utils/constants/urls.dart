class EUrls {
  /// Base URLs
  static const String BASE_URL = "https://10.0.2.2:8080";
  static const String IOS_BASE_URL = "https://192.168.1.185:8080";
  static const String PROD_URL = "https://api.emotioncheckinsystem.com";

  /// ANDROID
  static const String LOGIN_ENDPOINT_ANDROID = '$PROD_URL/api/v1/login';
  static const String HISTORY_ENDPOINT_ANDROID = '$PROD_URL/api/v1/user/my-history';
  static const String CHECK_IN_ENDPOINT_ANDROID = '$PROD_URL/api/v1/user/check-in';

  /// IOS
  static const String LOGIN_ENDPOINT_IOS = '$PROD_URL/api/v1/login';
  static const String HISTORY_ENDPOINT_IOS = '$PROD_URL/api/v1/user/my-history';
  static const String CHECK_IN_ENDPOINT_IOS = '$PROD_URL/api/v1/user/check-in';

  /// Development Endpoints
  static const String DEV_LOGIN_ENDPOINT_ANDROID = '$BASE_URL/api/v1/login';
  static const String DEV_HISTORY_ENDPOINT_ANDROID = '$BASE_URL/api/v1/user/my-history';
  static const String DEV_CHECK_IN_ENDPOINT_ANDROID = '$BASE_URL/api/v1/user/check-in';

  static const String DEV_LOGIN_ENDPOINT_IOS = '$IOS_BASE_URL/api/v1/login';
  static const String DEV_HISTORY_ENDPOINT_IOS = '$IOS_BASE_URL/api/v1/user/my-history';
  static const String DEV_CHECK_IN_ENDPOINT_IOS = '$IOS_BASE_URL/api/v1/user/check-in';
}