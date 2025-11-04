import 'dart:async';
import 'dart:convert';
import 'package:emc_mob/enums/tokens.dart';
import 'package:emc_mob/providers/check_in_provider.dart';
import 'package:emc_mob/screens/auth/login_screen.dart';
import 'package:emc_mob/utils/constants/debug.dart';
import 'package:emc_mob/utils/constants/status.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

/// This provider:
/// - Manages user login/logout operations.
/// - Stores and retrieves authentication tokens securely.
/// - Backend handles token refresh automatically via auth middleware.
/// - Loads user data from secure storage.
/// - Provides authentication status to the app.
class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  Future<bool> loginWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse(EUrls.LOGIN_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        /// Extract tokens from response body
        String? accessToken = responseBody['accessToken'];
        String? refreshToken = responseBody['refreshToken'];

        String? fullName = responseBody['fullName'];
        String? userEmail = responseBody['email'];

        if (accessToken != null && refreshToken != null) {
          await _saveTokens(accessToken, refreshToken);

          _userName = fullName;
          _userEmail = userEmail;
          _accessToken = accessToken;

          /// Save to secure storage
          await _secureStorage.write(
              key: ETokens.userName.name, value: _userName);
          await _secureStorage.write(
              key: ETokens.userEmail.name, value: _userEmail);

          notifyListeners();

          /// Send request to server only when user do login and successfully login to avoid unnecessary api calls
          if (context.mounted) {
            await context.read<CheckInProvider>().fetchCheckInsWithContext(context);
          }
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.body}');
        if (context.mounted) {
          try {
            final errorBody = jsonDecode(response.body);
            final errorMessage = errorBody['message'] ?? 'Login failed';
            EHelperFunctions.showSnackBar(context, errorMessage);
          } catch (e) {
            EHelperFunctions.showSnackBar(context, 'Login failed');
          }
        }
      }
    } on TimeoutException {
      debugPrint("Login timeout: The request took too long to respond.");
      if (context.mounted) {
        EHelperFunctions.showSnackBar(context, "Request timed out. Please try again later.");
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (context.mounted) {
        EHelperFunctions.showSnackBar(context, e.toString());
      }
    }
    return false;
  }

  Future<void> restoreUserInfo() async {
    _userName = await _secureStorage.read(key: ETokens.userName.name);
    _userEmail = await _secureStorage.read(key: ETokens.userEmail.name);
    notifyListeners();
  }

  Future<bool> ensureValidToken() async {
    String? storedRefreshToken =
    await _secureStorage.read(key: ETokens.refreshToken.name);
    if (storedRefreshToken == null) return false;

    try {
      /// Check refresh token expiration
      DateTime expirationTime =
      JwtDecoder.getExpirationDate(storedRefreshToken);
      Duration timeUntilExpiry = expirationTime.difference(DateTime.now());

      if (timeUntilExpiry.isNegative) {
        debugPrint("Refresh token has expired. User needs to log in again.");
        return false;
      }

      debugPrint(
          "Refresh token is valid for ${timeUntilExpiry.inDays} days.");
      return true;
    } catch (e) {
      debugPrint("Refresh token validation error: $e");
      return false;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: ETokens.accessToken.name, value: accessToken);
    await _secureStorage.write(
        key: ETokens.refreshToken.name, value: refreshToken);
  }


  /// The backend auth middleware automatically rotates tokens and returns
  /// new ones in response headers (x-access-token, x-refresh-token).
  Future<void> updateTokensFromHeaders(Map<String, String> headers) async {
    String? newAccessToken = headers['x-access-token'];
    String? newRefreshToken = headers['x-refresh-token'];

    if (newAccessToken != null && newRefreshToken != null) {
      await _saveTokens(newAccessToken, newRefreshToken);
      _accessToken = newAccessToken;
      notifyListeners();
      debugPrint("Tokens updated from backend rotation");
    }
  }

  Future<void> logout(BuildContext context) async {
    await _secureStorage.delete(key: ETokens.accessToken.name);
    await _secureStorage.delete(key: ETokens.refreshToken.name);
    await _secureStorage.delete(key: ETokens.userName.name);
    await _secureStorage.delete(key: ETokens.userEmail.name);
    _accessToken = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
    if (context.mounted) {
      await context.read<CheckInProvider>().clearData();
    }
    if (context.mounted) {
      EHelperFunctions.navigateToScreen(context, const LoginScreen());
    }
  }
}