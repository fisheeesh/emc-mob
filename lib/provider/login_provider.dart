import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emotion_check_in_app/enums/tokens.dart';
import 'package:emotion_check_in_app/provider/check_in_provider.dart';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _authToken;
  String? get authToken => _authToken;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

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
  Future<bool> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          debugPrint("Allowing self-signed certificate for $host");
          return true;
        };
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? ETexts.LOGIN_ENDPOINT_IOS : ETexts.LOGIN_ENDPOINT_ANDROID),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        String? authToken = response.headers[ETexts.AUTHORIZATION];
        String? refreshToken = response.headers[ETexts.REFRESH];

        if (authToken != null && refreshToken != null) {
          // debugPrint('Refresh Token: $refreshToken');
          await _saveTokens(authToken, refreshToken);
          _decodeUserInfoFromToken(authToken);
          _authToken = authToken;
          notifyListeners();
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
      debugPrint('Login timeout: The request took too long to respond.');
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, 'Request timed out. Please try again.');
      }
    } on SocketException {
      debugPrint('Login error: No internet connection.');
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, 'No internet connection. Please check your network.');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if(context.mounted){
        EHelperFunctions.showSnackBar(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  /// Decodes and extracts user information from the JWT token.
  ///
  /// This method takes the authentication token, decodes it, and extracts the
  /// username (from the 'claims' field). The extracted username is stored in memory
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
      _userName = decodedToken['username'];
      _userEmail = decodedToken['sub'];
      notifyListeners();

      // Save username and use email securely
      _secureStorage.write(key: ETokens.userName.name, value: _userName);
      _secureStorage.write(key: ETokens.userEmail.name, value: _userEmail);
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
    String? storedRefreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);
    if (storedRefreshToken == null) {
      debugPrint("No refresh token available.");
      return false;
    }

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(EHelperFunctions.isIOS() ? ETexts.REFRESH_ENDPOINT_IOS : ETexts.REFRESH_ENDPOINT_ANDROID),
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

  /// Restores the stored userInfo from secure storage.
  ///
  /// This method retrieves the username and user email saved during a previous login session.
  /// It updates the `_userName` and ``_userEmail variables and notifies listeners to reflect the change.
  ///
  /// If either username or user email is not found in storage, both `_userName` and `_useEmail` remains `null`.
  ///
  /// Effects:
  /// - Reads the username and user email from FlutterSecureStorage.
  /// - Updates `_userName` and `_userEmail` with the retrieved value.
  /// - Notifies listeners of the change.
  Future<void> restoreUserInfo() async {
    _userName = await _secureStorage.read(key: ETokens.userName.name);
    _userEmail = await _secureStorage.read(key: ETokens.userEmail.name);
    notifyListeners();
  }

  /// Ensures the authentication token is valid, using the refresh token.
  ///
  /// This method checks the stored refresh token's expiration time. If the refresh
  /// token is still valid, it attempts to refresh the authentication token.
  /// If the refresh token is expired, it returns `false`, forcing the user to log in again.
  ///
  /// Returns:
  /// - `true` if the refresh token is valid and the auth token is refreshed.
  /// - `false` if the refresh token has expired or an error occurs.
  ///
  /// Effects:
  /// - Reads the refresh token from FlutterSecureStorage.
  /// - Checks its expiration time using JWT decoding.
  /// - If expired, returns `false` to require user login.
  /// - If valid, calls `refreshToken()` to update the auth token.
  Future<bool> ensureValidToken() async {
    String? storedRefreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);
    if (storedRefreshToken == null) return false;

    try {
      // Check refresh token expiration
      DateTime expirationTime = JwtDecoder.getExpirationDate(storedRefreshToken);
      Duration timeUntilExpiry = expirationTime.difference(DateTime.now());

      // If refresh token is expired, return false (force login)
      if (timeUntilExpiry.isNegative) {
        debugPrint("Refresh token has expired. User needs to log in again.");
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