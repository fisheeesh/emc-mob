import 'dart:convert';
import 'dart:io';
import 'package:emc_mob/enums/tokens.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EmployeeService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getEmployeeData() async {
    try {
      /// Get tokens from secure storage
      final accessToken = await _secureStorage.read(key: ETokens.accessToken.name);
      final refreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse(EUrls.EMP_DATA_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'x-refresh-token': refreshToken ?? '',
          'x-platform': 'mobile',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load employee data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employee data: $e');
    }
  }

  Future<Map<String, dynamic>> updateEmployeeData({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required DateTime birthdate,
    File? avatarFile,
  }) async {
    try {
      final accessToken = await _secureStorage.read(key: ETokens.accessToken.name);
      final refreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      /// Create multipart request
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(EUrls.UPDATE_EMP_DATA_ENDPOINT),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'x-refresh-token': refreshToken ?? '',
        'x-platform': 'mobile',
      });

      request.fields['id'] = id.toString();
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;

      final birthdateUtc = DateTime.utc(
        birthdate.year,
        birthdate.month,
        birthdate.day,
      );
      request.fields['birthdate'] = birthdateUtc.toIso8601String();

      debugPrint('Sending birthdate: ${birthdateUtc.toIso8601String()}');
      debugPrint('Avatar file provided: ${avatarFile != null}');

      /// Add avatar file if provided
      if (avatarFile != null) {
        debugPrint('Adding avatar file: ${avatarFile.path}');

        final fileExists = await avatarFile.exists();
        debugPrint('File exists: $fileExists');

        if (!fileExists) {
          throw Exception('Avatar file does not exist at path: ${avatarFile.path}');
        }

        /// Get file extension
        String fileName = avatarFile.path.split('/').last;

        /// Determine content type based on file extension
        String contentType = 'image/jpeg';
        if (fileName.toLowerCase().endsWith('.png')) {
          contentType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        } else if (fileName.toLowerCase().endsWith('.webp')) {
          contentType = 'image/webp';
        }

        debugPrint('File content type: $contentType');
        debugPrint('File size: ${await avatarFile.length()} bytes');

        /// Use http.MultipartFile.fromPath with explicit contentType
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        );

        request.files.add(multipartFile);
        debugPrint('Avatar file added to request');
        debugPrint('Multipart filename: ${multipartFile.filename}');
        debugPrint('Multipart length: ${multipartFile.length}');
        debugPrint('Multipart field: ${multipartFile.field}');
        debugPrint('Multipart contentType: ${multipartFile.contentType}');
      }

      debugPrint('Sending request to: ${request.url}');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files count: ${request.files.length}');
      if (request.files.isNotEmpty) {
        debugPrint('File field name: ${request.files.first.field}');
        debugPrint('File name: ${request.files.first.filename}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update employee data');
      }
    } catch (e) {
      debugPrint('Error in updateEmployeeData: $e');
      throw Exception('Error updating employee data: $e');
    }
  }
}