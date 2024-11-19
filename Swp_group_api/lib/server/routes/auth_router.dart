import 'dart:convert';

import 'package:backend/server/base_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'auth_router.g.dart';

class AuthRouter extends BaseRouter {
  AuthRouter(super.db, super.config);

  /// This endpoint authenticates a user. The 'email' and 'password' parameters
  /// are required and passed as a JSON body. The response is another JSON body
  /// that contains a token if the authentication is successful. Alongside the
  /// authentication token, a refresh token is handed out that may be used to
  /// refresh the authentication token periodically, see the endpoint
  /// [refresh].
  ///
  /// To refresh the authentication token, the refresh token must be passed to
  /// the endpoint [refresh]. The refresh token is valid for a certain number of
  /// days, as defined by the server configuration.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the token. The token is a string that must be included in the
  /// headers of future requests to authenticate using the _Bearer_ scheme that
  /// is defined in RFC 6750.
  ///
  /// If the authentication fails, the response will have a status code of 401
  /// and the message will indicate that the authentication failed.
  ///
  /// ****This endpoint does not require a valid auth token.****
  /// 
  /// ****This endpoint does not require a valid API token.****
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/login
  ///
  /// {
  ///  "email":"user@uni-bremen.de",
  ///  "password":"password"
  /// }
  ///
  /// {
  ///   "data": {
  ///     "token":"eyJhbG...",
  ///     "refresh": "eyR5cI...",
  ///     "userId": 1
  ///   "},
  ///   "status":200,
  ///   "success":true,
  ///   "message":"Authenticated"
  /// }
  /// ```
  @Route.post('/login')
  Future<Response> authenticate(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['email', 'password']);

        final String? email = body['email'];
        final String? password = body['password'];

        return Response.ok(
            jsonEncode(await userService.authenticateUser(email, password)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint refreshes an authentication token. The 'refresh' parameter
  /// is required and passed as a JSON body, where the value is the refresh
  /// token handed out during the authentication process. The response is a JSON
  /// body that contains a new authentication token and a new refresh token,
  /// if the refresh token is valid.
  ///
  /// Once successfully authenticated, the new authentication token should be
  /// included in the headers of future requests to authenticate using the
  /// _Bearer_ scheme that is defined in RFC 6750. The new refresh token may be
  /// used to refresh the authentication token periodically, whilst the old
  /// refresh token loses its validity upon use.
  ///
  /// **This endpoint does not require a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/refresh
  ///
  /// {
  ///  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  /// }
  ///
  /// {
  ///   "data": {
  ///     "token": "eyJcCI6IkpXVCJ9...",
  ///     "refresh": "eyJ2I6IxVCJ9...",
  ///   },
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Token refreshed"
  /// }
  /// ```
  @Route.post('/refresh')
  Future<Response> refresh(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body =
            await utils.getBodyOrNullMap(request, requiredFields: ['refresh']);

        final String? token = body['refresh'];

        return Response.ok(jsonEncode(await userService.refreshToken(token)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint revokes an authentication token. The 'refresh' parameter is
  /// required and passed as a JSON body. The response is a JSON body that
  /// contains a message if the token was successfully revoked. Once invalidated
  /// the token may no longer be used to authenticate requests. The original
  /// authentication token will keep its validity until it expires.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/logout
  ///
  /// {
  ///   "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Token revoked"
  /// }
  /// ```
  @Route.post('/logout')
  Future<Response> revokeToken(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body =
            await utils.getBodyOrNullMap(request, requiredFields: ['refresh']);

        final String? token = body['refresh'];

        return Response.ok(jsonEncode(await userService.logout(token)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint generates an API token. The 'email' and 'days' parameters
  /// are required and passed as a JSON body. The response is a JSON body
  /// that contains the generated token if the generation is successful.
  ///
  /// The email of the user for which the token is generated must be a valid
  /// address conforming to the RFC 5322 standard. The domain may be limited to
  /// a certain domain according to the server configuration.
  ///
  /// The number of days the token is valid must be a positive integer and may
  /// be limited to a certain number of days according to the server
  /// configuration.
  ///
  /// On success, the response will have a status code of 200 and an according
  /// message. The message will indicate that the token was generated and sent
  /// to the user's email address.
  ///
  /// If the generation fails, the response will return with an error code and
  /// the message will indicate that the token could not be generated.
  ///
  /// **This endpoint does not require valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST api/auth/generate_api_token
  ///
  /// {
  ///  "email":"user@uni-bremen.de",
  ///  "days":30
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "success": true,
  ///   "status": 200,
  ///   "message":"Token generated and sent to user's email address"
  /// }
  /// ```
  @Route.post('/generate_api_token')
  Future<Response> getApiToken(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['email', 'days']);

        final String? email = body['email'];
        final int? days = body['days'] is int ? body['days'] : null;

        return Response.ok(
            jsonEncode(await apiService.generateApiToken(email,
                daysValid: days)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint registers a new user. The email, password, and name
  /// parameters are required and passed as a JSON body. The response is a JSON
  /// body that contains the user's data if the registration is successful.
  ///
  /// The following body fields are required:
  ///
  /// - email: The email address of the user.
  /// - password: The password of the user.
  /// - name: The name of the user.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the user's id in the system. The id is a positive integer that
  /// uniquely identifies the user.
  ///
  /// If the registration fails, the response will have an error code and the
  /// message will indicate that the registration failed.
  ///
  /// **This endpoint does not require a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/register
  ///
  /// {
  ///   "email":"user@uni-bremen.de",
  ///   "password":"password",
  ///   "name":"User"
  /// }
  ///
  /// {
  ///   "data":{
  ///     "result":3
  ///   },
  ///   "status":200,
  ///   "success":true,
  ///   "message":"User created, please check email for activation."
  /// }
  @Route.post('/register')
  Future<Response> register(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils.getBodyOrNullMap(request,
            requiredFields: ['email', 'password', 'name']);

        final String? email = body['email'];
        final String? password = body['password'];
        final String? name = body['name'];

        return Response.ok(
            jsonEncode(await userService.registerUser(name, email, password)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint verifies a user's registration. The [token] parameter is
  /// required and passed as a path parameter.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the user was successfully activated.
  ///
  /// If the verification fails, the response will have an error code and the
  /// message will indicate that the user could not be activated.
  ///
  /// **This endpoint does not require a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/auth/verify_registration/eyJhbGciOiJI...
  ///
  /// {
  ///  "data": {},
  ///  "status": 200,
  ///  "success": true,
  ///  "message": "User activated"
  /// }
  /// ```
  @Route.get('/verify_registration/<token>')
  Future<Response> verifyRegistration(Request request, String token) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final String token = args['token'];
        return Response.ok(jsonEncode(await userService.activateUser(token)),
            headers: {'Content-Type': 'application/json'});
      }, request,
          args: {'token': token}, isApiProtected: false, isProtected: false);

  /// This endpoint sends a password reset email to the user. The email
  /// parameter is required and passed as a JSON body. The response is a JSON
  /// body that contains a message if the email was successfully sent.
  ///
  /// The email of the user must be a valid address conforming to the RFC 5322
  /// standard. The domain may be limited to a certain domain according to the
  /// server configuration.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the email was sent to the user's
  /// email.
  ///
  /// Should any error occur, the response will have an error code and the
  /// message indicative of the fault at hand.
  ///
  /// **This endpoint does not require a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/reset_password
  ///
  /// {
  ///   "email":"user@uni-bremen.de",
  /// }
  ///
  /// {
  ///  "data": {},
  ///  "status": 200,
  ///  "success": true,
  ///  "message": "Password reset email sent"
  /// }
  /// ```
  @Route.post('/reset_password')
  Future<Response> resetPassword(Request request) async {
    return utils.checkedRoute(
        (final Request request, Map<String, dynamic> args) async {
      final Map<String, dynamic> body =
          await utils.getBodyOrNullMap(request, requiredFields: ['email']);

      final String? email = body['email'];

      return Response.ok(jsonEncode(await userService.resetPassword(email)),
          headers: {'Content-Type': 'application/json'});
    }, request, isApiProtected: false, isProtected: false);
  }

  /// This endpoint verifies a user's password reset. The [token] parameter is
  /// required and passed as a path parameter. The new password is passed as a
  /// JSON body, where the password parameter is required and the value
  /// expected to be an non-empty string. The maximum length of the password
  /// may be limited by the server configuration. The response is an empty JSON
  /// body if the verification is successful. The message will indicate that the
  /// user was successfully verified.
  ///
  /// Note that the password may not be reset if
  ///
  /// - the token is invalid or expired.
  /// - the enclosed email address does not match the user's email address.
  /// - the new password does not meet the server's password requirements.
  ///
  /// The requirements for a password are defined by the server and may include
  /// a minimum length, a maximum length. If the email address enclosed is not
  /// known, e.g., because the user has been deleted, the response will indicate
  /// that an error occurred.
  ///
  /// **This endpoint does not require a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/verify_password_reset
  ///
  /// {
  ///  "token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  ///  "password":"new_password"
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Password reset"
  /// }
  /// ```
  @Route.post('/verify_password_reset')
  Future<Response> verifyPasswordReset(Request request) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body =
            await utils.getBodyOrNullMap(request, requiredFields: ['password']);

        final String? token = body['token'];
        final String? password = body['password'];

        return Response.ok(
            jsonEncode(await userService.changePassword(token, password)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: false);

  /// This endpoint updates a user's password. The id, old_password, and
  /// new_password parameters are required and passed as a JSON body. The
  /// function will update the password of the user with the given id if the
  /// old password matches the current password.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the password was successfully updated.
  ///
  /// If the update fails, the response will have an error code and the message
  /// will indicate that the password could not be updated.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint does not require a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/auth/update_password
  ///
  /// {
  ///  "id":1,
  ///  "old_password":"password",
  ///  "new_password":"new_password"
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Password updated"
  /// }
  /// ```
  @Route.post('/update_password')
  Future<Response> updatePassword(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils.getBodyOrNullMap(request,
            requiredFields: ['id', 'old_password', 'new_password']);

        final int requesterId = await utils.getRequesterId(request);
        final String? oldPassword = body['password'];
        final String? newPassword = body['new_password'];

        // The id may be null, in which case the requester's id is used.
        late final int? userId;
        if (body['id'] == null) {
          userId = requesterId;
        } else if (body['id'] is int) {
          userId = body['id'];
        } else {
          userId = null;
        }

        return Response.ok(
            jsonEncode(await userService.updateUserPassword(
                requesterId, userId, oldPassword, newPassword)),
            headers: {'Content-Type': 'application/json'});
      }, request, isApiProtected: false, isProtected: true);

  @override
  Router get router => _$AuthRouterRouter(this);
}
