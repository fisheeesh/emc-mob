class EUrls {
  /// Base URLs
  static const String ANDROID_BASE_URL = "https://10.0.2.2:8080";
  static const String IOS_BASE_URL = "https://192.168.1.185:8080";
  static const String PROD_URL = "https://api.emotioncheckinsystem.com";

  /// Production endpoints
  static const String LOGIN_ENDPOINT = '$PROD_URL/api/v1/login';
  static const String HISTORY_ENDPOINT = '$PROD_URL/api/v1/user/my-history';
  static const String CHECK_IN_ENDPOINT = '$PROD_URL/api/v1/user/check-in';
  static const String EMOTION_CATEGORIES_ENDPOINT =
      '$PROD_URL/api/v1/user/emotion-categories';
  static const String EMP_DATA_ENDPOINT = '$PROD_URL/api/v1/user/emp-data';
  static const String UPDATE_EMP_DATA_ENDPOINT =
      '$PROD_URL/api/v1/user/emp-data';

  /// Development Endpoints
  /// Android
  static const String DEV_LOGIN_ENDPOINT_ANDROID =
      '$ANDROID_BASE_URL/api/v1/login';
  static const String DEV_HISTORY_ENDPOINT_ANDROID =
      '$ANDROID_BASE_URL/api/v1/user/my-history';
  static const String DEV_CHECK_IN_ENDPOINT_ANDROID =
      '$ANDROID_BASE_URL/api/v1/user/check-in';
  static const String DEV_EMOTION_CATEGORIES_ENDPOINT_ANDROID =
      '$ANDROID_BASE_URL/api/v1/user/emotion-categories';
  static const String DEV_EMP_DATA_ENDPOINT_ANDROID =
      '$ANDROID_BASE_URL/api/v1/user/emp-data';

  /// IOS
  static const String DEV_LOGIN_ENDPOINT_IOS = '$IOS_BASE_URL/api/v1/login';
  static const String DEV_HISTORY_ENDPOINT_IOS =
      '$IOS_BASE_URL/api/v1/user/my-history';
  static const String DEV_CHECK_IN_ENDPOINT_IOS =
      '$IOS_BASE_URL/api/v1/user/check-in';
  static const String DEV_EMOTION_CATEGORIES_ENDPOINT_IOS =
      '$IOS_BASE_URL/api/v1/user/emotion-categories';
  static const String DEV_EMP_DATA_ENDPOINT_IOS =
      '$IOS_BASE_URL/api/v1/user/emp-data';
}
