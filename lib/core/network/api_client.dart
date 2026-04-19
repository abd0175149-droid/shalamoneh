import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shalmoneh_app/core/network/api_exceptions.dart';
import 'package:shalmoneh_app/core/network/api_response.dart';

/// API Client — الربط مع Backend
/// يدعم: GET, POST, PUT, DELETE مع JWT Auth
class ApiClient {
  // في التطوير المحلي
  static const String _devBaseUrl = 'http://localhost:4050/api';
  // في الإنتاج — عبر Cloudflare Tunnel
  static const String _prodBaseUrl = 'https://shalamoneh.grade.sbs/api';

  static String get baseUrl => kDebugMode ? _devBaseUrl : _prodBaseUrl;

  String? _token;

  /// تعيين Token بعد تسجيل الدخول
  void setToken(String token) => _token = token;

  /// حذف Token عند تسجيل الخروج
  void clearToken() => _token = null;

  /// Headers الافتراضية
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ══════════════════════════════════════════
  //  HTTP Methods
  // ══════════════════════════════════════════

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════
  //  Response Handling
  // ══════════════════════════════════════════

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(json, fromJson);
    }

    throw ApiException.fromStatusCode(
      response.statusCode,
      json['message'] as String?,
    );
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error.toString().contains('SocketException')) {
      return ApiException.noInternet();
    }
    if (error.toString().contains('TimeoutException')) {
      return ApiException.timeout();
    }
    return ApiException.unknown(error.toString());
  }
}

/// Singleton instance
final apiClient = ApiClient();
