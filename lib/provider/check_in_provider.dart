import 'dart:convert';
import 'dart:io';
import 'package:emotion_check_in_app/enums/tokens.dart';
import 'package:emotion_check_in_app/provider/login_provider.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/check_in.dart';
import 'package:http/http.dart' as http;

class CheckInProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<CheckIn> _checkIns = [];

  List<CheckIn> get checkIns => _checkIns;

  /// Common method for sending authorized requests
  Future<http.Response?> _makeAuthorizedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    String? token = await _secureStorage.read(key: ETokens.authToken.name);
    if (token == null || token.isEmpty) {
      debugPrint("No token found in storage.");
      return null;
    }

    // Ensure token does not have "Bearer " prefix
    token = token.trim();
    if (token.startsWith("Bearer ")) {
      token = token.substring(7);
    }

    debugPrint("Using Token: '$token'");

    // Check token expiration
    if (JwtDecoder.isExpired(token)) {
      debugPrint("Token is expired.");
      return null;
    }

    DateTime expirationTime = JwtDecoder.getExpirationDate(token);
    Duration timeUntilExpiry = expirationTime.difference(DateTime.now());

    // If token is expiring in ≤30 minutes, refresh it
    if (timeUntilExpiry.inMinutes <= 30) {
      debugPrint("Auth token is expiring in ${timeUntilExpiry.inMinutes} minutes. Refreshing...");
      LoginProvider loginProvider = LoginProvider();
      bool refreshed = await loginProvider.refreshToken();
      if (refreshed) {
        token = await _secureStorage.read(key: ETokens.authToken.name);
        if (token == null || token.isEmpty) {
          debugPrint("Error: Token refresh failed.");
          return null;
        }
        token = token.trim();
        if (token.startsWith("Bearer ")) {
          token = token.substring(7);
        }
        debugPrint("New auth token obtained: '$token'");
      } else {
        debugPrint("Failed to refresh token.");
        return null;
      }
    }

    // Create HttpClient with certificate bypass
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(httpClient);

    // Prepare request
    final uri = Uri.parse(endpoint);
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    http.Response response;

    try {
      if (method == "POST") {
        response = await ioClient.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == "GET") {
        response = await ioClient.get(uri, headers: headers);
      } else {
        debugPrint("Unsupported HTTP method: $method");
        return null;
      }
      return response;
    } catch (e) {
      debugPrint("Error during HTTP request: $e");
      return null;
    }
  }

  /// Sends a check-in to the backend
  Future<void> sendCheckIn(BuildContext context, String emoji, String feelingText) async {
    String moodMessage = "$emoji $feelingText";
    final endpoint = EHelperFunctions.isIOS() ? ETexts.CHECK_IN_ENDPOINT_IOS : ETexts.CHECK_IN_ENDPOINT_ANDROID;

    final response = await _makeAuthorizedRequest(
      method: "POST",
      endpoint: endpoint,
      body: {"moodMessage": moodMessage},
    );

    if (response != null && response.statusCode == 200) {
      debugPrint("Check-in successful: $moodMessage");
    } else {
      debugPrint("Failed to send check-in: ${response?.body}");
    }
  }

  /// Fetches check-in data from the backend
  Future<void> fetchCheckIns() async {
    final endpoint = EHelperFunctions.isIOS() ? ETexts.HISTORY_ENDPOINT_IOS : ETexts.HISTORY_ENDPOINT_ANDROID;

    final response = await _makeAuthorizedRequest(
      method: "GET",
      endpoint: endpoint,
    );

    if (response != null && response.statusCode == 200) {
      List<String> timestamps = List<String>.from(jsonDecode(response.body));
      _checkIns = timestamps.map((timestamp) => CheckIn.fromJson({'timestamp': timestamp})).toList();
      debugPrint("Check-ins fetched successfully: $_checkIns");
      notifyListeners();
    } else {
      debugPrint("Failed to fetch check-ins: ${response?.body}");
    }
  }

  /// Get check-in by a specific date
  CheckIn? getCheckInByDate(DateTime date) {
    return _checkIns.cast<CheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.timestamp.day == date.day &&
          checkIn.timestamp.month == date.month &&
          checkIn.timestamp.year == date.year,
      orElse: () => null,
    );
  }

  /// Get today's check-in
  CheckIn? get todayCheckIn {
    final today = DateTime.now();
    return _checkIns.cast<CheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.timestamp.day == today.day &&
          checkIn.timestamp.month == today.month &&
          checkIn.timestamp.year == today.year,
      orElse: () => null,
    );
  }
}