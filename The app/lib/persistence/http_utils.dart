import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';
import '../exceptions/api_exceptions.dart';

class HttpUtils {
  static Map<String, String> buildHeaders({
    final String? authToken,
    final String? apiToken,
    Map<String, String>? headers,
  }) {
    headers ??= {};

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    if (apiToken != null) {
      headers['ApiToken'] = apiToken;
    }

    return headers;
  }

  static Map<String, dynamic> handleResponse(final Response response) {
    late final Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw ApiServerException(
          'Response body is not a valid JSON', response.statusCode);
    }

    if (response.statusCode == HttpStatus.ok) {
      return body;
    } else if (response.statusCode >= HttpStatus.badRequest &&
        response.statusCode < HttpStatus.internalServerError) {
      throw ApiClientException(
          body['message'] ?? 'An unknown error occurred', response.statusCode);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw ApiServerException(
          body['message'] ?? 'An uknown error occured', response.statusCode);
    } else {
      throw ApiBaseException(
          'The server returned an unexcpected status', response.statusCode);
    }
  }

  static Future<Map<String, dynamic>> performDelete({
    required final Uri path,
    final String? authToken,
    final String? apiToken,
    Map<String, String>? headers,
  }) async {
    headers ??= {};

    final response = await Client().delete(
      path,
      headers: buildHeaders(
        authToken: authToken,
        apiToken: apiToken,
        headers: headers,
      ),
    );

    return HttpUtils.handleResponse(response);
  }

  static Future<Map<String, dynamic>> performGet({
    required final Uri path,
    final String? authToken,
    final String? apiToken,
    Map<String, String>? headers,
  }) async {
    headers ??= {};

    final response = await Client().get(
      path,
      headers: buildHeaders(
        authToken: authToken,
        apiToken: apiToken,
        headers: headers,
      ),
    );

    return HttpUtils.handleResponse(response);
  }

  static Future<Map<String, dynamic>> performPost({
    required final Uri path,
    final String? authToken,
    final String? apiToken,
    Map<String, String>? headers,
    final Map<String, dynamic>? body,
  }) async {
    headers ??= {};
    final response = await Client().post(
      path,
      headers: buildHeaders(
        authToken: authToken,
        apiToken: apiToken,
        headers: headers,
      ),
      body: jsonEncode(body),
      encoding: const Utf8Codec(),
    );

    return HttpUtils.handleResponse(response);
  }
}
