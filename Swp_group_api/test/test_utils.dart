import 'dart:convert';
import 'dart:io';

import 'package:backend/config/config.dart';
import 'package:backend/middleware/api_token_manager.dart';
import 'package:backend/middleware/auth_manager.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

enum Method { POST, GET, DELETE }

Future<http.Response> makeCall(final Method method, final Uri uri,
    {final Map<String, String>? headers,
    final Map<String, dynamic> body = const {}}) async {
  switch (method) {
    case Method.POST:
      return http.post(uri, headers: headers, body: jsonEncode(body));
    case Method.GET:
      return http.get(uri, headers: headers);
    case Method.DELETE:
      return http.delete(uri, headers: headers);
    default:
      throw Exception('Invalid method');
  }
}

Map<String, dynamic> getResponseData(
  final http.Response response, {
  final List<String> requiredFields = const [],
}) {
  final Map<String, dynamic> body = response.body.isEmpty
      ? <String, dynamic>{}
      : jsonDecode(response.body) as Map<String, dynamic>;

  expect(body.containsKey('data'), true);

  final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? {};

  for (final String field in requiredFields) {
    expect(data.containsKey(field), true);
  }

  return data;
}

String getAuthToken(final AuthManager manager, int userId) {
  return 'Bearer ${manager.generateAuthToken(userId)}';
}

String getApiToken(
    final ApiTokenManger manager, String email, final int daysValid) {
  return manager.generateToken(email, daysValid: daysValid);
}

Future<http.Response> callEndPoint({
  required Method method,
  required final Config config,
  required final String path,
  final bool expectApiAuthorized = false,
  final String apiToken = '',
  final bool expectAuthenticated = false,
  final String authToken = '',
  final int expectedStatus = 200,
  final String expectedMessage = '',
  final Map<String, dynamic> body = const {},
}) async {
  final String host = config.API_HOST;
  final int port = config.API_PORT;

  // Construct the URI.
  final Uri uri = Uri.parse('http://$host:$port$path');

  Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  // Check if the API token is required in combination with authenticated.
  if (expectApiAuthorized && (authToken.isEmpty || apiToken.isEmpty)) {
    throw Exception('API and authentication token required');
  }

  if (expectAuthenticated && authToken.isEmpty) {
    throw Exception('Authentication token required');
  }

  if (expectApiAuthorized) {
    await makeCall(method, uri, headers: headers).then((response) {
      expect(response.statusCode, 403);
    }).catchError((error, stackTrace) {
      fail('Call failed: $error');
    });
  }

  if (apiToken.isNotEmpty) {
    headers['ApiToken'] = apiToken;
  }

  if (expectAuthenticated) {
    await makeCall(method, uri, headers: headers).then((response) {
      expect(response.statusCode, 403);
    }).catchError((error, stackTrace) {
      fail('Call failed: $error');
    });
  }

  if (authToken.isNotEmpty) {
    headers['Authorization'] = authToken;
  }

  final http.Response response =
      await makeCall(method, uri, headers: headers, body: body);

  if (expectedMessage.isNotEmpty) {
    final Map<String, dynamic> data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    expect(data.containsKey('message'), true);
    expect(data['message'], expectedMessage);
  }

  expect(response.statusCode, expectedStatus);

  return response;
}
