import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emotion_check_in_app/enums/tokens.dart';
import 'package:emotion_check_in_app/provider/check_in_provider.dart';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/utils/constants/debug.dart';
import 'package:emotion_check_in_app/utils/constants/status.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/constants/urls.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

/// **LoginProvider** is responsible for handling user authentication, token management, and login state.
///
/// This provider:
/// - Manages user login/logout operations.
/// - Stores and retrieves authentication tokens securely.
/// - Handles token refresh logic.
/// - Loads user data from secure storage.
/// - Provides authentication status to the app.
class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _authToken;
  String? get authToken => _authToken;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  /// **Logs in the user using email and password.**
  ///
  /// This method sends a POST request to the authentication endpoint with the provided credentials.
  /// If login is successful, it extracts the authentication and refresh tokens, decodes user details,
  /// and stores them securely.
  ///
  /// **Returns:**
  /// - `true` if login is successful.
  /// - `false` if login fails (due to incorrect credentials, network issues, or server errors).
  Future<bool> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? EUrls.LOGIN_ENDPOINT_IOS : EUrls.LOGIN_ENDPOINT_ANDROID),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String? authToken = response.headers[ETexts.AUTHORIZATION];
        String? refreshToken = response.headers[ETexts.REFRESH];

        if (authToken != null && refreshToken != null) {
          await _saveTokens(authToken, refreshToken);
          _decodeUserInfoFromToken(authToken);
          _authToken = authToken;
          notifyListeners();
          /// Send request to server only when user do login and successfully login to avoid unnecessary api calss
          await context.read<CheckInProvider>().fetchCheckIns();
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.body}');
        if(context.mounted){
          EHelperFunctions.showSnackBar(context, response.body);
        }
      }
    } on TimeoutException {
      debugPrint(EDebug.REQ_TIME_OUT);
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, EStatus.REQ_TIME_OUT);
      }
    } on SocketException {
      debugPrint(EDebug.NO_INTERNET);
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, EStatus.NO_INTERNET);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, e.toString());
      }
    }
    return false;
  }

  /// **Decodes user information from the JWT token and stores it.**
  ///
  /// Extracts the username and email from the token payload and saves them securely.
  ///
  /// **Parameters:**
  /// - `token`: The JWT authentication token received from the server.
  void _decodeUserInfoFromToken(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _userName = decodedToken['username'];
      _userEmail = decodedToken['sub'];
      notifyListeners();

      /// Save username and use email securely
      _secureStorage.write(key: ETokens.userName.name, value: _userName);
      _secureStorage.write(key: ETokens.userEmail.name, value: _userEmail);
    } catch (e) {
      debugPrint("Error decoding token: $e");
    }
  }

  /// **Refreshes the authentication token using the stored refresh token.**
  ///
  /// If the refresh token is valid, it requests a new authentication token and updates stored credentials.
  ///
  /// **Returns:**
  /// - `true` if the token refresh is successful.
  /// - `false` if the refresh token is invalid or expired.
  Future<bool> refreshToken() async {
    String? storedRefreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);
    if (storedRefreshToken == null) {
      debugPrint(EDebug.NO_REFRESH_TOKEN);
      return false;
    }

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? EUrls.REFRESH_ENDPOINT_IOS : EUrls.REFRESH_ENDPOINT_ANDROID),
        headers: {
          'Content-Type': 'application/json',
          'Refresh': storedRefreshToken,
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        String? newAuthToken = response.headers[ETexts.AUTHORIZATION];
        String? newRefreshToken = response.headers[ETexts.REFRESH];

        if (newAuthToken != null && newRefreshToken != null) {
          await _saveTokens(newAuthToken, newRefreshToken);
          _decodeUserInfoFromToken(newAuthToken);
          _authToken = newAuthToken;
          notifyListeners();
          debugPrint(EDebug.SUC_REFRESH);
          return true;
        }
      } else {
        debugPrint("Refresh token failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Refresh token error: $e");
    }

    return false;
  }

  /// **Restores the stored user info from secure storage.**
  ///
  /// If user data exists, it updates `_userName` and `_userEmail`, otherwise, they remain `null`.
  Future<void> restoreUserInfo() async {
    _userName = await _secureStorage.read(key: ETokens.userName.name);
    _userEmail = await _secureStorage.read(key: ETokens.userEmail.name);
    notifyListeners();
  }


  /// **Ensures the authentication token is valid.**
  ///
  /// If the refresh token is still valid, it refreshes the authentication token.
  /// Continuously refresh the authentication token as long as the user is active.
  ///
  /// - If the user remains active, their session is extended by refreshing the token.
  /// - If the user is inactive for **1 week**, they will be required to log in again.
  /// - This ensures secure, time-limited access without forcing frequent logins.
  ///
  /// **Returns:**
  /// - `true` if the token refresh is successful.
  /// - `false` if the refresh token has expired.
  Future<bool> ensureValidToken() async {
    String? storedRefreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);
    if (storedRefreshToken == null) return false;

    try {
      // Check refresh token expiration
      DateTime expirationTime = JwtDecoder.getExpirationDate(storedRefreshToken);
      Duration timeUntilExpiry = expirationTime.difference(DateTime.now());

      // If refresh token is expired, return false (force login)
      if (timeUntilExpiry.isNegative) {
        debugPrint(EDebug.REFRESH_EXP);
        return false;
      }

      // If refresh token is still valid, attempt to refresh auth token
      debugPrint("Refresh token is valid for ${timeUntilExpiry.inMinutes} minutes.");

      return await refreshToken();
    } catch (e) {
      debugPrint("Refresh token validation error: $e");
      return false;
    }
  }

  /// Stores authentication and refresh tokens securely.
  ///
  /// This method saves the provided authentication and refresh tokens
  /// in FlutterSecureStorage for future authentication sessions.
  ///
  /// Parameters:
  /// - `authToken`: The JWT authentication token received from the server.
  /// - `refreshToken`: The refresh token used to obtain a new authentication token.
  ///
  /// Effects:
  /// - Saves both tokens in secure storage.
  /// - Overwrites any existing stored tokens.
  Future<void> _saveTokens(String authToken, String refreshToken) async {
    await _secureStorage.write(key: ETokens.authToken.name, value: authToken);
    await _secureStorage.write(key: ETokens.refreshToken.name, value: refreshToken);
  }

  /// **Logs out the user and clears stored authentication data.**
  ///
  /// After logging out, it navigates the user back to the `LoginScreen`.
  /// Clear all tokens from FlutterSecureStorage and clear user's check-in data from sqlite.
  Future<void> logout(BuildContext context) async {
    await _secureStorage.delete(key: ETokens.authToken.name);
    await _secureStorage.delete(key: ETokens.refreshToken.name);
    await _secureStorage.delete(key: ETokens.userName.name);
    _authToken = null;
    _userName = null;
    notifyListeners();
    await context.read<CheckInProvider>().clearData();
    if(context.mounted){
      EHelperFunctions.navigateToScreen(context, LoginScreen());
    }
  }
}