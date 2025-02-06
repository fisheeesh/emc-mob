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

  String? _userName;  // ✅ Store username
  String? get userName => _userName;

  /// **1️⃣ Login and Store Tokens**
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(ETexts.LOGIN_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        String? authToken = response.headers['authorization'];
        String? refreshToken = response.headers['refresh'];

        if (authToken != null && refreshToken != null) {
          await _saveTokens(authToken, refreshToken);
          _decodeUserInfoFromToken(authToken); // ✅ Decode username from token
          _authToken = authToken;
          notifyListeners();
          _isLoading = false;
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// **2️⃣ Decode Username & Email from Token**
  void _decodeUserInfoFromToken(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _userName = decodedToken['sub']; // ✅ Extract username
      notifyListeners();

      // Save username securely
      _secureStorage.write(key: 'username', value: _userName);
    } catch (e) {
      debugPrint("Error decoding token: $e");
    }
  }

  /// **3️⃣ Refresh Token When Needed**
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
        Uri.parse(ETexts.REFRESH_ENDPOINT),
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
          _decodeUserInfoFromToken(newAuthToken); // ✅ Decode username from refreshed token
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

  /// **4️⃣ Restore Username on App Start**
  Future<void> restoreUserName() async {
    _userName = await _secureStorage.read(key: 'username'); // ✅ Restore username
    notifyListeners();
  }

  /// **5️⃣ Check If Token Needs Refresh (Threshold: 30 minutes)**
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

  /// **6️⃣ Save Tokens Securely**
  Future<void> _saveTokens(String authToken, String refreshToken) async {
    await _secureStorage.write(key: 'auth_token', value: authToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// **7️⃣ Logout & Clear Tokens**
  Future<void> logout(BuildContext context) async {
    _isLoading = false; // ✅ Reset loading state
    notifyListeners();

    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'username'); // ✅ Clear username
    _authToken = null;
    _userName = null;
    notifyListeners();
    EHelperFunctions.navigateToScreen(context, LoginScreen());
  }
}