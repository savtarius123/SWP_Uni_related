import 'dart:convert';

import 'package:backend/server/base_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'user_router.g.dart';

class UserRouter extends BaseRouter {
  UserRouter(super.db, super.config);

  /// This endpoint can be used to retrieve a user by their ID. The ID must be
  /// a positive integer passed as a path parameter. The response will be a JSON
  /// object containing the user's information.
  ///
  /// On success this endpoint will return a status code of 200 and a JSON
  /// map containing the user's information, containing the following fields:
  ///
  /// - id: The user's ID.
  /// - email: The user's email address.
  /// - name: The user's name.
  /// - role: The user's role.
  /// - active: A boolean indicating whether the user is active.
  ///
  /// The user id is a positive integer greater than 0. The email is a string
  /// confining to the email format, as defined in the RFC 5322 standard. The
  /// email address may be subject to a system wide restriction, allowing for a
  /// specific top-level domain only. The name is any non-empty string of
  /// utf-8 characters, but may be
  ///
  /// On Failure this endpoint will return any status code 400, indicating that
  /// the request was malformed or any 500 status code, indicating that an
  /// internal server error occurred. The data returned will be an empty JSON
  /// object.
  ///
  /// *This endpoint requires a valid auth token.*
  /// *This endpoint requires a valid API token.*
  ///
  /// ## Example
  ///
  /// ```http
  ///
  /// GET /api/user/get/id/1
  ///
  /// {
  ///  "id": 1,
  ///  "email": "user@uni-bremen.de",
  ///  "name": "User",
  ///  "role": 0,
  ///  "active": true
  /// }
  /// ```
  @Route.get('/get/id/<id>')
  Future<Response> getUser(Request request, String id) => utils.checkedRoute(
        (final Request request, final Map<String, dynamic> args) async {
          final int? userId = int.tryParse(args['userId']);

          return Response.ok(jsonEncode(await userService.getUserById(userId)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
        args: {'userId': id},
      );

  /// This endpoint can be used to retrieve a user by their email address. The
  /// email address must be a string passed as a path parameter. The response
  /// will be a JSON object containing the user's information, comprising:
  ///
  /// - id: The user's ID.
  /// - email: The user's email address.
  /// - name: The user's name.
  /// - role: The user's role.
  /// - active: A boolean indicating whether the user is active.
  ///
  /// The email address must be a string confining to the email format, as
  /// defined in the RFC 5322 standard. The email address may be subject to a
  ///
  /// On success this endpoint will return a status code of 200 and a JSON
  /// map containing the user's information.
  ///
  /// On Failure this endpoint will return any status code 400, indicating that
  /// the request was malformed or any 500 status code, indicating that an
  ///
  /// *This endpoint requires a valid auth token.*
  /// *This endpoint requires a valid API token.*
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/user/email/user%40uni-bremen.de
  ///
  /// {
  ///   "id": 1,
  ///   "email": "user@uni-bremen.de",
  ///   "name": "User Name",
  ///   "role": 0,
  ///   "active": true
  /// }
  /// ```
  @Route.get('/get/email/<email>')
  Future<Response> getUserByEmail(Request request, String email) =>
      utils.checkedRoute(
        (final Request request, final Map<String, dynamic> args) async {
          final String userEmail = args['email'];

          return Response.ok(
              jsonEncode(await userService.getUserByEmail(userEmail)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
        args: {'email': email},
      );

  /// This endpoint can be used to retrieve a user's groups. The user's ID must
  /// be a positive integer passed as a path parameter. The page and page size
  /// must be positive integers passed as path parameters. The response will be
  /// a JSON object containing the user's groups.
  ///
  /// The [page] and [pagesize] parameters must be positive integers greater
  /// than 0.
  /// The user [id] must be a positive integer greater than 0.
  ///
  /// On success this endpoint will return a status code of 200 and a JSON
  /// array containing the user's groups. Each group will be represented by a
  /// JSON object containing the following fields:
  ///
  /// - id: The group's ID.
  /// - name: The group's name.
  /// - description: The group's description.
  ///
  /// Should the user not be a member of any groups, the response will be an
  /// empty JSON array.
  ///
  /// In case the user cannot be found, the an appropriate status code will be
  /// returned, indicating that the request was malformed using a 400 status.
  /// In any other case, a 500 status code will be returned, indicating that an
  /// internal server error occurred.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/user/get/id/1/groups/1/10
  ///
  /// {
  ///  "data": [
  ///   {
  ///    "id": 1,
  ///    "name": "Group 1",
  ///    "description": "This is group 1"
  ///    },
  ///    ...
  ///  ],
  ///  "success": true
  ///  "status": 200
  ///  "message": "Groups retrieved successfully"
  /// }
  /// ```
  @Route.get('/get/id/<id>/groups/<page>/<pagesize>')
  Future<Response> getUserGroups(
          Request request, String id, String page, String pagesize) =>
      utils.checkedRoute(
        (final Request request, final Map<String, dynamic> args) async {
          final int? userId = int.tryParse(args['userId']);
          final int? page = int.tryParse(args['page']);
          final int? pageSize = int.tryParse(args['pageSize']);

          return Response.ok(
              jsonEncode(
                  await groupService.getGroupsByUser(userId, page, pageSize)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
        args: {'userId': id, 'page': page, 'pageSize': pagesize},
      );

  /// This endpoint can be used to update a user's name. The user's ID must be a
  /// positive integer passed as a path parameter. The name must be a string
  /// passed as a JSON object in the request body. The response will be a JSON
  /// object containing the user's information.
  ///
  /// The user [id] must be a positive integer greater than 0. The name must be
  /// a non-empty string of utf-8 characters, which may be subject to a system
  /// wide restriction on the length.
  ///
  /// On success this endpoint will return a status code of 200 and an empty
  /// JSON object.
  ///
  /// In case the user cannot be found, the an appropriate status code will be
  /// returned, indicating that the request was malformed using a 400 status.
  /// In any other case, a 500 status code will be returned, indicating that an
  /// internal server error occurred.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/user/update/name
  ///
  /// {
  ///   "data": {},
  ///   "success": true,
  ///   "status": 200,
  ///   "message": "Name updated successfully"
  /// }
  /// ```
  @Route.post('/update/name')
  Future<Response> updateUserName(Request request) async => utils.checkedRoute(
        (final Request request, Map<String, dynamic> args) async {
          final Map<String, dynamic> body = await utils
              .getBodyOrNullMap(request, requiredFields: ['userId', 'name']);

          final int requesterId = await utils.getRequesterId(request);
          final String? userName = body['name'];
          final int? userId = body['userId'] is int ? body['userId'] : null;

          return Response.ok(
              jsonEncode(await userService.updateUserName(
                  requesterId, userId, userName)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
      );

  /// This endpoint can be used to update a user's password. The user's ID must
  /// be a positive integer passed as a path parameter. The old password and the
  /// new password must be strings passed as a JSON object in the request body.
  /// The response will be an empty JSON object, indicating whether the password
  /// was updated successfully.
  ///
  /// The user id must be a positive integer greater than 0. The old password
  /// must be a non-empty string of utf-8 characters, which may be subject to a
  /// system wide restriction on the length. The new password must be a
  /// non-empty string of utf-8 characters, which may be subject to a system
  /// wide restriction on the length. The old password must match the user's
  /// current password. Any mismatch will result in a 400 status code.
  ///
  /// On success this endpoint will return a status code of 200 and an empty
  /// JSON object.
  ///
  /// In case the user cannot be found, the an appropriate status code will be
  /// returned, indicating that the request was malformed using a 400 status.
  /// In any other case, a 500 status code will be returned, indicating that an
  /// internal server error occurred.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/user/update/password
  ///
  /// {
  ///  "userId": 1,
  ///  "oldPassword": "oldPassword",
  ///  "newPassword": "newPassword"
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "success": true,
  ///   "status": 200,
  ///   "message": "Password updated successfully"
  /// }
  /// ```
  @Route.post('/update/password')
  Future<Response> updateUserPassword(Request request) async =>
      utils.checkedRoute(
        (final Request request, Map<String, dynamic> args) async {
          final Map<String, dynamic> body = await utils.getBodyOrNullMap(
              request,
              requiredFields: ['userId', 'oldPassword', 'newPassword']);

          final int requesterId = await utils.getRequesterId(request);
          final String? oldPassword = body['oldPassword'];
          final String? newPassword = body['newPassword'];
          final int? userId = body['userId'] is int ? body['userId'] : null;

          return Response.ok(
              jsonEncode(await userService.updateUserPassword(
                  requesterId, userId, oldPassword, newPassword)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
      );

  /// This endpoint can be used to delete a user. The user's ID must be a
  /// positive integer passed as a path parameter. The response will be an empty
  /// JSON object, indicating whether the user was deleted successfully.
  ///
  /// The user id must be a positive integer greater than 0. The user will be
  /// deleted from the database and all associated data will be removed,
  /// including groups, group memberships, and any other data associated with
  /// the user.
  ///
  /// Note that only the user themselves or an admin can delete a user. Any
  /// other request will result in a 400 type status code.
  ///
  /// On success this endpoint will return a status code of 200 and an empty
  /// JSON object.
  ///
  /// In case the user cannot be found, the an appropriate status code will be
  /// returned, indicating that the request was malformed using a 400 status.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// DELETE /api/user/delete/id/1
  ///
  /// {
  ///  "data": {},
  ///  "success": true,
  ///  "status": 200,
  ///  "message": "User deleted successfully"
  /// }
  /// ```
  @Route.delete('/delete/id/<id>')
  Future<Response> deleteUser(Request request, String id) async =>
      utils.checkedRoute(
        (final Request request, Map<String, dynamic> args) async {
          final int requesterId = await utils.getRequesterId(request);
          final int? userId = int.tryParse(args['userId']);

          return Response.ok(
              jsonEncode(await userService.deleteUser(requesterId, userId)),
              headers: {'Content-Type': 'application/json'});
        },
        request,
        args: {'userId': id},
      );

  @override
  Router get router => _$UserRouterRouter(this);
}
