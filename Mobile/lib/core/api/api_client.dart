import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    _checkSimulation();
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConstants.timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    _checkSimulation();
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    _checkSimulation();
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConstants.timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network error occurred: ${e.toString()}');
    }
  }

  void _checkSimulation() {
    if (ApiConstants.simulateFailure) {
      throw NetworkException('Simulated network failure.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    switch (statusCode) {
      case 400:
        throw ValidationException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Validation error',
        );
      case 401:
        throw UnauthorizedException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Unauthorized',
        );
      case 404:
        throw NotFoundException(
          body is Map && body['message'] != null
              ? body['message']
              : 'Not found',
        );
      default:
        throw ApiException('Server error occurred', statusCode);
    }
  }
}
