import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _authToken;
  String? get authToken => _authToken;

  String? _userName;
  String? get userName => _userName;

  /// Logs in the user using email and password.
  ///
  /// This method sends a POST request to the authentication endpoint with the provided
  /// credentials. If the login is successful, it extracts the authentication token,
  /// refresh token, and user information from the server's response headers.
  ///
  /// The tokens are securely stored using FlutterSecureStorage, and the username is
  /// extracted from the JWT token and saved for future use.
  ///
  /// If login fails due to incorrect credentials, network issues, or server errors,
  /// the method returns `false`.
  ///
  /// Returns:
  /// - `true` if login is successful and tokens are stored.
  /// - `false` if login fails.
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? ETexts.LOGIN_ENDPOINT_IOS : ETexts.LOGIN_ENDPOINT_ANDROID),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String? authToken = response.headers['authorization'];
        String? refreshToken = response.headers['refresh'];

        if (authToken != null && refreshToken != null) {
          await _saveTokens(authToken, refreshToken);
          _decodeUserInfoFromToken(authToken);
          _authToken = authToken;
          notifyListeners();
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  /// Decodes and extracts user information from the JWT token.
  ///
  /// This method takes the authentication token, decodes it, and extracts the
  /// username (from the 'sub' field). The extracted username is stored in memory
  /// and securely saved using FlutterSecureStorage for persistence.
  ///
  /// If decoding fails (e.g., invalid or malformed token), it logs an error.
  ///
  /// Parameters:
  /// - `token`: The JWT authentication token received from the server.
  ///
  /// Effects:
  /// - Updates `_userName` with the extracted username.
  /// - Saves the username securely for future use.
  /// - Notifies listeners of changes.
  void _decodeUserInfoFromToken(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _userName = decodedToken['sub'];
      notifyListeners();

      // Save username securely
      _secureStorage.write(key: 'username', value: _userName);
    } catch (e) {
      debugPrint("Error decoding token: $e");
    }
  }

  /// Refreshes the authentication token using the stored refresh token.
  ///
  /// This method retrieves the refresh token from secure storage and sends a request
  /// to the server's refresh endpoint. If the refresh is successful, it extracts and
  /// stores the new authentication and refresh tokens, then decodes the username from
  /// the new token.
  ///
  /// If the refresh token is missing, expired, or invalid, the method logs an error
  /// and returns `false`.
  ///
  /// Returns:
  /// - `true` if the token refresh is successful and new tokens are stored.
  /// - `false` if the refresh token is missing, expired, or the request fails.
  ///
  /// Effects:
  /// - Updates `_authToken` with the new authentication token.
  /// - Saves new tokens securely in FlutterSecureStorage.
  /// - Extracts and updates the username from the refreshed token.
  /// - Notifies listeners of changes.
  Future<bool> refreshToken() async {
    String? storedRefreshToken = await _secureStorage.read(key: 'refresh_token');
    if (storedRefreshToken == null) {
      debugPrint("No refresh token available.");
      return false;
    }

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? ETexts.LOGIN_ENDPOINT_IOS : ETexts.LOGIN_ENDPOINT_ANDROID),
        headers: {
          'Content-Type': 'application/json',
          'Refresh': storedRefreshToken,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String? newAuthToken = response.headers['authorization'];
        String? newRefreshToken = response.headers['refresh'];

        if (newAuthToken != null && newRefreshToken != null) {
          await _saveTokens(newAuthToken, newRefreshToken);
          _decodeUserInfoFromToken(newAuthToken);
          _authToken = newAuthToken;
          notifyListeners();
          debugPrint("Token refreshed successfully.");
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

  /// Restores the stored username from secure storage.
  ///
  /// This method retrieves the username saved during a previous login session.
  /// It updates the `_userName` variable and notifies listeners to reflect the change.
  ///
  /// If no username is found in storage, `_userName` remains `null`.
  ///
  /// Effects:
  /// - Reads the username from FlutterSecureStorage.
  /// - Updates `_userName` with the retrieved value.
  /// - Notifies listeners of the change.
  Future<void> restoreUserName() async {
    _userName = await _secureStorage.read(key: 'username');
    notifyListeners();
  }

  /// Ensures the authentication token is valid and refreshes it if needed.
  ///
  /// This method checks the expiration time of the stored authentication token.
  /// If the token is set to expire within the next 30 minutes, it automatically
  /// attempts to refresh it using the stored refresh token.
  ///
  /// If the token is still valid, it returns `true`. If the token is expired or
  /// an error occurs, it returns `false`.
  ///
  /// Returns:
  /// - `true` if the token is valid or successfully refreshed.
  /// - `false` if the token is expired and cannot be refreshed.
  ///
  /// Effects:
  /// - Reads the authentication token from secure storage.
  /// - Decodes its expiration time and compares it with the current time.
  /// - Calls `refreshToken()` if the expiration is within 30 minutes.
  /// - Logs relevant messages for debugging.
  Future<bool> ensureValidToken() async {
    String? storedAuthToken = await _secureStorage.read(key: 'auth_token');
    if (storedAuthToken == null) return false;

    try {
      DateTime expirationTime = JwtDecoder.getExpirationDate(storedAuthToken);
      Duration timeUntilExpiry = expirationTime.difference(DateTime.now());

      // **Threshold: Refresh token if it expires within the next 30 minutes**
      if (timeUntilExpiry.inMinutes <= 30) {
        debugPrint("Token is about to expire in ${timeUntilExpiry.inMinutes} minutes. Refreshing...");
        return await refreshToken();
      }

      debugPrint("Token is still valid for ${timeUntilExpiry.inMinutes} minutes.");
      return true;
    } catch (e) {
      debugPrint("Token validation error: $e");
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
    await _secureStorage.write(key: 'auth_token', value: authToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Logs out the user and clears stored authentication data.
  ///
  /// This method removes all stored authentication details, including the
  /// authentication token, refresh token, and username. It also resets
  /// `_authToken` and `_userName` to `null`, ensuring the user is fully logged out.
  ///
  /// After clearing credentials, it navigates the user back to the `LoginScreen`.
  ///
  /// Effects:
  /// - Resets `_isLoading` to `false`.
  /// - Deletes stored tokens and username from secure storage.
  /// - Updates `_authToken` and `_userName` to `null`.
  /// - Notifies listeners to reflect the logout state.
  /// - Redirects the user to the `LoginScreen`.
  Future<void> logout(BuildContext context) async {
    _isLoading = false;
    notifyListeners();

    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'username');
    _authToken = null;
    _userName = null;
    notifyListeners();
    EHelperFunctions.navigateToScreen(context, LoginScreen());
  }
}