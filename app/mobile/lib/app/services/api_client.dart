import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_response.dart';

class ApiClient {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  String? _token;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _initialized = true;
  }

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    bool auth = false,
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJsonT,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers(auth: auth));
    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    bool auth = false,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    bool auth = false,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    bool auth = false,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    bool auth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String path, {
    required List<int> bytes,
    required String filename,
    String fieldName = 'image',
    bool auth = false,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$path'),
    );
    if (auth && _token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.files.add(http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: filename,
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    return ApiResponse(
      success: success,
      data: body['data'] as Map<String, dynamic>?,
      message: body['message'] as String?,
    );
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final message = body['message'] as String?;

    if (!success) {
      return ApiResponse(
        success: false,
        message: message,
        needsVerification: body['needsVerification'] as bool?,
        email: body['email'] as String?,
      );
    }

    return ApiResponse<T>.fromJson(body, fromJsonT);
  }
}
