import 'dart:convert';
import 'dart:io';

import 'package:backend/config/config.dart';
import 'package:backend/exception/service_exception.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/service/api_service.dart';
import 'package:backend/service/user_service.dart';
import 'package:backend/util/logger_provider.dart';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';

class RouterUtils {
  late final UserService _userService;
  late final ApiService _apiService;
  late final Logger log;

  RouterUtils(final AppDatabase db, final Config config)
      : _userService = UserService(db, config),
        _apiService = ApiService(db, config),
        log = LoggerProvider.instance;

  /// Wraps a route function with error handling and authentication checks.
  ///
  /// @param route The route function to call. Must be an async function that
  /// takes a [Request], a [Map<String, dynamic>] as arguments and returns a
  /// [Future<Response>].
  ///
  /// This function will catch any exceptions thrown by the route function and
  /// return an appropriate response. The response consists of a JSON object
  /// with the following fields:
  ///
  /// - data: the data returned by the route function
  /// - status: the HTTP status code of the response
  /// - success: a boolean indicating whether the request was successful
  /// - message: a message describing the result of the request
  ///
  /// @param request The request object.
  ///
  /// @param args A map of path parameters.
  ///
  /// @param isApiProtected Whether the route requires a valid API token.
  ///
  /// @param isProtected Whether the route requires a valid authentication token.
  ///
  /// @returns A [Response] object.
  ///
  /// @example
  /// ```dart
  /// Future<Response> getGroup(Request request, String arg1) async =>
  ///    utils.checkedRoute(
  ///       (final Request request, Map<String, dynamic> args) async {
  ///  final String? arg = int.tryParse(args['arg1'] ?? '');
  ///
  ///  ...
  ///
  ///  // Do something with the argument and return a response.
  ///
  ///  ...
  ///
  /// }, request, args: {'arg1': arg1});
  Future<Response> checkedRoute(
      final Future<Response> Function(Request, Map<String, dynamic> args) route,
      final Request request,
      {final Map<String, dynamic> args = const {},
      isApiProtected = true,
      isProtected = true}) async {
    String? clientAddress = null;

    try {
      clientAddress =
          (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address;
      log.d('Request from $clientAddress: ${request.url}');
      log.d('Headers: ${request.headers}');
    } catch (e) {
      log.w('Failed to log request information: $e');
    } finally {
      clientAddress ??= 'unknown';
    }

    try {
      if (isApiProtected && !await isApiAuthorized(request)) {
        log.i('Invalid API token from $clientAddress');
        log.d('Headers: ${request.headers}');
        log.d('Client address: $clientAddress');

        List<String> errors = getClaimErrors(getApiToken(request));

        return Response.forbidden(
            jsonEncode({
              'data': {},
              'status': 401,
              'success': false,
              'message': errors.isNotEmpty ? errors.first : 'Invalid token.'
            }),
            headers: {
              'Content-Type': 'application/json',
            });
      }

      if (isProtected && !await isAuthenticated(request)) {
        log.i('Invalid authentication from $clientAddress');
        log.d('Headers: ${request.headers}');
        log.d('Client address: $clientAddress');

        List<String> errors = getClaimErrors(getAuthToken(request));

        return Response.forbidden(
            jsonEncode({
              'data': {},
              'status': 401,
              'success': false,
              'message': errors.isNotEmpty ? errors.first : 'Invalid token.'
            }),
            headers: {
              'Content-Type': 'application/json',
            });
      }

      // URL decode path parameters.
      final Map<String, dynamic> decodedArgs = {};
      args.forEach((key, value) {
        decodedArgs[key] = Uri.decodeComponent(value);
      });

      // Create a list of arguments to pass to the route function.
      final List requestArgs = [request, decodedArgs];

      // Make the call to the route function.
      return await Function.apply(route, requestArgs);
    } on ServiceException catch (e) {
      switch (e.errorCode) {
        case HttpErrorStatus.notFound:
          log.i('Not found: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.notFound(jsonEncode(e.data), headers: {
            'Content-Type': 'application/json',
          });
        case HttpErrorStatus.conflict:
          log.i('Conflict: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response(409, body: jsonEncode(e.data), headers: {
            'Content-Type': 'application/json',
          });
        case HttpErrorStatus.unauthorized:
          log.i('Unauthorized: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.forbidden(jsonEncode(e.data), headers: {
            'Content-Type': 'application/json',
          });
        case HttpErrorStatus.forbidden:
          log.i('Forbidden: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.forbidden(jsonEncode(e.data), headers: {
            'Content-Type': 'application/json',
          });
        case HttpErrorStatus.badRequest:
          log.i('Bad request: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.badRequest(body: jsonEncode(e.data), headers: {
            'Content-Type': 'application/json',
          });
        case HttpErrorStatus.internalServerError:
          log.w('Internal server error: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.internalServerError(
              body: jsonEncode(e.data),
              headers: {
                'Content-Type': 'application/json',
              });
        default:
          log.w('Unknown error: ${e.data}');
          log.d('Headers: ${request.headers}');
          log.d('Client address: $clientAddress');

          return Response.internalServerError(
              body: jsonEncode(e.data),
              headers: {
                'Content-Type': 'application/json',
              });
      }
    } on JWTError catch (e) {
      log.i(e.toString());
      log.d('Headers: ${request.headers}');
      log.d('Client address: $clientAddress');

      return Response.forbidden(
          jsonEncode({
            'data': {},
            'status': 403,
            'success': false,
            'message': 'Invalid token: ${e.message}'
          }),
          headers: {
            'Content-Type': 'application/json',
          });
    } on FormatException catch (e) {
      log.w(e.toString());
      log.d('Headers: ${request.headers}');
      log.d('Client address: $clientAddress');

      return Response.badRequest(
          body: jsonEncode({
            'data': {},
            'status': 400,
            'success': false,
            'message': 'Invalid request: ${e.message}'
          }),
          headers: {
            'Content-Type': 'application/json',
          });
    } on Exception catch (e) {
      log.w(e.toString());
      log.d('Headers: ${request.headers}');
      log.d('Client address: $clientAddress');

      return Response.internalServerError(
          body: jsonEncode({
            'data': {},
            'status': 500,
            'success': false,
            'message': 'Unknown error'
          }),
          headers: {
            'Content-Type': 'application/json',
          });
    }
  }

  /// Reads the request body and returns it as a map.
  ///
  /// @param request The request object.
  ///
  /// @param requiredFields A list of fields that are required in the request
  /// body.
  ///
  /// @returns A [Future] that resolves to a map of the request body.
  Future<Map<String, dynamic>> getBodyOrNullMap(final Request request,
      {final List<String> requiredFields = const []}) async {
    final String bodyString = await request.readAsString();
    if (bodyString.isEmpty) {
      return {};
    }

    // Set empty fields to null.
    Map<String, dynamic> data = json.decode(bodyString);
    for (var field in requiredFields) {
      if (!data.containsKey(field)) {
        data[field] = null;
      }
    }

    return data;
  }

  /// Convinience method to get the API token from the request.
  ///
  /// @param request The request object.
  ///
  /// @returns The API token.
  ///
  /// @throws JWTError If the API token is missing.
  String getApiToken(final Request request) {
    final String? authHeader = request.headers['ApiToken'];

    if (authHeader == null) {
      throw JWTError('Invalid request: Missing API token');
    }

    return authHeader;
  }

  /// Convinience method to get the authentication token from the request.
  ///
  /// @param request The request object.
  ///
  /// @returns A the authentication token.
  ///
  /// @throws JWTError If the authentication token is missing.
  String getAuthToken(final Request request) {
    final String? authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      throw JWTError('Missing or invalid authorization header');
    }

    final List<String> parts = authHeader.split(' ');
    if (parts.length != 2) {
      throw JWTError('Malformed authorization header');
    }

    return parts[1];
  }

  /// Checks if the user is authenticated.
  ///
  /// @param request The request object.
  ///
  /// @returns A [Future] that resolves to a boolean indicating whether the user
  /// is authenticated.
  Future<bool> isAuthenticated(final Request request) async {
    final String token = getAuthToken(request);

    return await _userService.isAuthenticated(token);
  }

  /// In case of an invalid token, this method returns a list of errors.
  /// The errors are related to the token's signature and claims.
  ///
  /// @param token The token to validate.
  ///
  /// @returns A list of errors.
  List<String> getClaimErrors(String token) {
    return _userService.getClaimErrors(token);
  }

  /// Checks if the API token is authorized.
  ///
  /// @param request The request object.
  ///
  /// @returns A [Future] that resolves to a boolean indicating whether the API
  /// token is authorized.
  Future<bool> isApiAuthorized(final Request request) async {
    final String token = getApiToken(request);

    return await _apiService.isAuthorized(token);
  }

  /// Gets the requester's id from the request.
  ///
  /// @param request The request object.
  ///
  /// @returns A [Future] that resolves to the requester's id.
  Future<int> getRequesterId(final Request request) async {
    final String token = getAuthToken(request);

    return await _userService.getRequesterId(token);
  }
}
