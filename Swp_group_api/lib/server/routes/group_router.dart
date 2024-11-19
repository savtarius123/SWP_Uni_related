import 'dart:convert';

import 'package:backend/server/base_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'group_router.g.dart';

class GroupRouter extends BaseRouter {
  GroupRouter(super.db, super.config);

  /// This endpoint retrieves a group by its id. The [id] parameter is required
  /// and passed as a path parameter. It must be an integer not smaller than 1,
  /// as 0 is reserved for the non-existent group. The response is a JSON
  /// representation of the group.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the group data. The data will have the following fields:
  /// - id: the group's id
  /// - name: the group's name
  /// - description: the group's description
  ///
  /// If the group is not found, the response will have a status code of 404
  /// and the message will indicate that the group was not found.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/get/id/1
  ///
  /// {
  ///   "data": {
  ///     "id":1,
  ///     "name":"Test Group",
  ///     "description":"This is a test group"
  ///   },
  ///   "status":200,
  ///   "success":true,
  ///   "message":"Group found"
  /// }
  /// ```
  @Route.get('/get/id/<id>')
  Future<Response> getGroup(Request request, String id) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final int? groupId = int.tryParse(args['groupId'] ?? '');

        return Response.ok(jsonEncode(await groupService.getGroupById(groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'groupId': id});

  /// This endpoint retrieves a group by its name. The [name] parameter is
  /// required and passed as a path parameter. The response is a JSON
  /// representation of the group. The name must be a non-empty string, which
  /// may be limited to a certain length, depending on the server configuration.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the group data. The data will have the following fields:
  ///
  /// - id: the group's id
  /// - name: the group's name
  /// - description: the group's description
  ///
  /// If the group is not found, the response will have a status code of 404
  /// and the message will indicate that the group was not found.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/get/name/Test_Group
  ///
  ///
  @Route.get('/get/name/<name>')
  Future<Response> getGroupByName(Request request, String name) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final String? name = args['name'];

        return Response.ok(jsonEncode(await groupService.getGroupByName(name)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'name': name});

  /// This endpoint retrieves all users in a group. The [id] parameter is
  /// required and passed as a path parameter. It must be an integer not smaller
  /// than 1, as 0 is reserved for the non-existent group. The response is a
  /// JSON representation of the group's users.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the group's users. The data will be a list of user objects,
  /// each with the following fields:
  ///
  /// - id: the user's id
  /// - name: the user's name
  /// - email: the user's email
  /// - active: whether the user is active
  ///
  /// If the group is not found, the response will have a status code of 404
  /// and the message will indicate that the group was not found.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/get/id/1/members/0/8
  ///
  /// {
  ///  "data": [
  ///     {
  ///       "id": 1,
  ///       "name": "Test User",
  ///       "email": "user@uni-bremen.de",
  ///       "active": true
  ///     },
  ///     ...
  ///   ],
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Group members found"
  /// }
  /// ```
  @Route.get('/get/id/<id>/members/<page>/<pagesize>')
  Future<Response> getGroupMembers(
          Request request, String id, String page, String pagesize) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final int? groupId = int.tryParse(args['groupId'] ?? '');
        final int? page = int.tryParse(args['page'] ?? '');
        final int? pageSize = int.tryParse(args['pageSize'] ?? '');

        return Response.ok(
            jsonEncode(
                await groupService.getUsersInGroup(groupId, page, pageSize)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'groupId': id, 'page': page, 'pageSize': pagesize});

  /// This endpoint retrieves all groups. The [page] and [pagesize] parameters
  /// are required and passed as path parameters. They must be integers not
  /// smaller than 0. Each page will contain at most [pagesize] groups. When
  /// thought of as a continuous enumeration, the first group is at position 0
  /// and a a pagesize of 10 will return groups 0-9 on the first page, 10-19 on
  /// the second, and so on. Internally the page is simply an offset multiplied
  /// by the pagesize.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the groups. The data will be a list of group objects,  found
  /// under the key data -> result. Each list entry contains a map with the
  /// following fields:
  ///
  /// - id: the group's id
  /// - name: the group's name
  /// - description: the group's description
  /// - ownerId: the group's owner's id
  ///
  /// If no groups are found, the response will return with an empty list.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/get/all/0/8
  ///
  /// {
  ///   "data": {
  ///     "result": [
  ///       {
  ///         "id": 1,
  ///         "name": "Test Group",
  ///         "description": "This is a test group",
  ///         "ownerId": 1
  ///       },
  ///       ...
  ///     ]
  ///   },
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Groups found"
  /// }
  /// ```
  @Route.get('/get/all/<page>/<pagesize>')
  Future<Response> getAllGroups(
          Request request, String page, String pagesize) =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final int? pageSize = int.tryParse(args['pageSize'] ?? '');
        final int? page = int.tryParse(args['page'] ?? '');

        return Response.ok(
            jsonEncode(await groupService.getAllGroups(page, pageSize)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'pageSize': pagesize, 'page': page});

  /// This endpoint updates the name of a group. The 'id' and 'name' parameters
  /// are required and passed as a JSON body. The 'id' must be an
  /// integer not smaller than 1, as 0 is reserved for the non-existent group.
  /// The 'name' must be a non-empty string, which may be limited to a certain
  /// length, depending on the server configuration. Note that only the group
  /// owner can update the group name or the admin.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the group was updated successfully.
  ///
  /// If the group is not found, the response will have a status code of 404
  /// and the message will indicate that the group was not found. Any other
  /// error will result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/update/name
  ///
  /// {
  ///  "id": 1,
  ///  "name": "New Group Name"
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Group name updated"
  /// }
  /// ```
  @Route.post('/update/name')
  Future<Response> updateGroup(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['id', 'name']);

        final int userId = await utils.getRequesterId(request);
        final String? groupName = body['name'];
        final int? groupId = body['id'] is int ? body['id'] : null;

        return Response.ok(
            jsonEncode(
                await groupService.updateGroupName(userId, groupId, groupName)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  /// This endpoint updates the description of a group. The 'id' and 'description'
  /// parameters are required and passed as a JSON body. The 'id' must be an
  /// integer not smaller than 1, as 0 is reserved for the non-existent group.
  /// The 'description' must be a non-empty string, which may be limited to a
  /// certain length, depending on the server configuration. Note that only the
  /// group owner can update the group description or the admin.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the group was updated successfully.
  ///
  /// If the group is not found, the response will have a status code of 404
  /// and the message will indicate that the group was not found. Any other
  /// error will result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/update/description
  ///
  /// {
  ///   "id": 1,
  ///   "description": "New Group Description"
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Group description updated"
  /// }
  /// ```
  @Route.post('/update/description')
  Future<Response> updateGroupDescription(Request request) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['id', 'description']);

        final int userId = await utils.getRequesterId(request);
        final String? groupDescription = body['description'];
        final int? groupId = body['id'] is int ? body['id'] : null;

        return Response.ok(
            jsonEncode(await groupService.updateGroupDescription(
                userId, groupId, groupDescription)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  /// This endpoint deletes a group. The [id] parameter is required and passed as
  /// a path parameter. It must be an integer not smaller than 1, as 0 is
  /// reserved for the non-existent group. Note that only the group owner can
  /// delete the group or the admin.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the group was deleted successfully.
  ///
  /// If the group is not found, the response will have a status code of 404 and
  /// the message will indicate that the group was not found. Any other error
  /// will result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// DELETE /api/group/delete/id/1
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Group deleted"
  /// }
  /// ```
  @Route.delete('/delete/id/<id>')
  Future<Response> deleteGroup(Request request, final String id) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final int? groupId = int.tryParse(args['groupId'] ?? '');
        final int userId = await utils.getRequesterId(request);

        return Response.ok(
            jsonEncode(await groupService.deleteGroup(userId, groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'groupId': id});

  /// This endpoint creates a group. The 'name' and 'description' parameters are
  /// required and passed as a JSON body. The 'name' and 'description' must be
  /// non-empty strings, which may be limited to a certain length, depending on
  /// the server configuration.
  ///
  /// Note that the group will not be created if
  ///
  /// - the group name is already in use.
  /// - the user has exceeded the maximum number of groups allowed.
  ///
  /// The maximum number of groups allowed is determined by the server
  /// configuration.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing any positive integer. The data will have the
  /// following fields:
  ///
  /// - result: the group's id
  ///
  /// If the group could not be created, either due to missing or malformed
  /// parameters, the response will have a status code of 400 and the message
  /// will indicate that the group could not be created. Any other error will
  /// result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/create
  ///
  /// {
  ///   "name": "New Group",
  ///   "description": "This is a new group"
  /// }
  ///
  /// {
  ///   "data": {
  ///     "result": 1
  ///   },
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Group created"
  /// }
  /// ```
  @Route.post('/create')
  Future<Response> createGroup(Request request) async => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['name', 'description']);

        final int userId = await utils.getRequesterId(request);
        final String? name = body['name'];
        final String? description = body['description'];

        return Response.ok(
            jsonEncode(await groupService.createGroupWithUser(
                userId, name, description)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  /// This endpoint invites a user to a group. The 'userId' and 'groupId'
  /// parameters are required and passed as a JSON body. The 'userId' and
  /// 'groupId' must be integers not smaller than 1, as 0 is reserved for the
  /// non-existent group. Both, the 'userId' and 'groupId' must be valid and
  /// existing entities in the database.
  ///
  /// The user can not be invited to a group if they
  ///
  /// - are the group owner.
  /// - are already a member of the group.
  /// - are already invited to the group.
  ///
  /// In the latter case, any pending invitation will be invalidated after a
  /// specific time period, determined by the server configuration. Note that
  /// only the group owner can invite users to the group or the admin.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the user was invited successfully.
  ///
  /// If the user could not be invited, either due to missing or malformed
  /// parameters, the response will have a status code of 400 and the message
  /// will indicate that the user could not be invited. Any other error will
  /// result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/invite
  ///
  /// {
  ///   "userId": 2,
  ///   "groupId": 1
  /// }
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "User invited"
  /// }
  /// ```
  @Route.post('/invite')
  Future<Response> addUserToGroup(Request request) => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body = await utils
            .getBodyOrNullMap(request, requiredFields: ['userId', 'groupId']);

        final int requesterId = await utils.getRequesterId(request);
        final int? userId = body['userId'] is int ? body['userId'] : null;
        final int? groupId = body['groupId'] is int ? body['groupId'] : null;

        return Response.ok(
            jsonEncode(await groupService.createInvitation(
                requesterId, userId, groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  /// This endpoint accepts an invitation to a group. The [token] parameter is
  /// required and passed as a path parameter. The [token] must be a valid
  /// invitation token, which is generated when a user is invited to a group.
  ///
  /// Note that invitations can only be accepted if
  ///
  /// - the user is not already a member of the group.
  /// - the invitation is still valid.
  ///
  /// In the latter case, any pending invitation will be invalidated after a
  /// specific time period, determined by the server configuration.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the invitation was accepted
  /// successfully.
  ///
  /// If the invitation could not be accepted, either due to missing or
  /// malformed parameters, the response will have a status code of 400 and the
  /// message will indicate that the invitation could not be accepted. Any other
  /// error will result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/accept/1234567890
  ///
  /// {
  ///   "data": {},
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "Invitation accepted"
  /// }
  /// ```
  @Route.get('/accept/<token>')
  Future<Response> acceptInvite(Request request, final String token) =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final String? token = args['token'];

        return Response.ok(
            jsonEncode(await groupService.acceptInvitation(token)),
            headers: {'Content-Type': 'application/json'});
      }, request,
          args: {'token': token}, isProtected: false, isApiProtected: false);

  /// This endpoint removes a user from a group. The 'userId' and 'groupId'
  /// parameters are required and passed as a JSON body. The 'userId' and
  /// 'groupId' must be integers not smaller than 1, as 0 is reserved for the
  /// non-existent group. Both, the 'userId' and 'groupId' must be valid and
  /// existing entities in the database.
  ///
  /// The user can not be removed from a group if
  ///
  /// - they are the owner of the group themselves.
  /// - the deletion was issued by a user not owning the group.
  /// - they are not a member of the group.
  ///
  /// If they are the last user in the group, the group will be deleted. This is
  /// only possible if the owner is removed from the group by the hands of an
  /// administator. Note that if the owner wants to leave the group, they must
  /// delete the group instead, using the delete endpoint.
  ///
  /// On success, the response will have a status code of 200 and an empty JSON
  /// body. The message will indicate that the user was removed successfully.
  ///
  /// If the user could not be removed, either due to missing or malformed
  /// parameters, the response will have a status code of 400 and the message
  /// will indicate that the user could not be removed. Any other error will
  /// result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/remove_user
  ///
  /// {
  ///  "userId": 2,
  ///  "groupId": 1
  /// }
  ///
  /// {
  ///  "data": {},
  ///  "status": 200,
  ///  "success": true,
  ///  "message": "User removed"
  /// }
  /// ```
  @Route.post('/remove_user')
  Future<Response> removeUserFromGroup(Request request) => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body =
            await utils.getBodyOrNullMap(request, requiredFields: ['groupId']);

        final int requesterId = await utils.getRequesterId(request);
        final int? userId = body['userId'] is int ? body['userId'] : null;
        final int? groupId = body['groupId'] is int ? body['groupId'] : null;

        return Response.ok(
            jsonEncode(await groupService.removeUserFromGroup(
                requesterId, userId, groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  /// This endpoint checks if a user owns a group. The 'userId' and 'groupId'
  /// parameters are required and passed as a JSON body. The 'userId' and
  /// 'groupId' must be integers not smaller than 1, as 0 is reserved for the
  /// non-existent group. Both, the 'userId' and 'groupId' must be valid and
  /// existing entities in the database.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing a boolean value indicating whether the user owns the group or
  /// not. The data will have the following fields:
  ///
  /// - result: a boolean value indicating if the user owns the group
  ///
  /// If the user ownership could not be checked, either due to missing or
  /// malformed parameters, the response will have a status code of 400 and the
  /// message will indicate that the user ownership could not be checked. Any
  /// other error will result in a status code of 500 and an error message.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// POST /api/group/check_ownership
  ///
  /// {
  ///   "userId": 2,
  ///   "groupId": 1
  /// }
  ///
  /// {
  ///   "data": {
  ///     "result": true
  ///   },
  ///   "status": 200,
  ///   "success": true,
  ///   "message": "User ownership checked"
  /// }
  /// ```
  @Route.post('/check_ownership')
  Future<Response> checkGroupOwnership(Request request) => utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final Map<String, dynamic> body =
            await utils.getBodyOrNullMap(request, requiredFields: ['groupId']);

        final int? userId = body['userId'] is int ? body['userId'] : null;
        final int? groupId = body['groupId'] is int ? body['groupId'] : null;

        return Response.ok(
            jsonEncode(await groupService.isGroupOwner(userId, groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request);

  @override
  Router get router => _$GroupRouterRouter(this);

  /// This endpoint retrieves the owner of a group. The [id] parameter is required
  /// and passed as a path parameter. It must be an integer not smaller than 1, as
  /// 0 is reserved for the non-existent group. The response is the id of the
  /// group's owner.
  ///
  /// On success, the response will have a status code of 200 and a JSON body
  /// containing the group owner's id. The data will have the following fields:
  ///
  /// - result: the group owner's id
  ///
  /// If the group is not found, the response will have a status code of 404 and
  /// the message will indicate that the group was not found.
  ///
  /// **This endpoint requires a valid auth token.**
  /// 
  /// **This endpoint requires a valid API token.**
  /// 
  ///
  /// ## Example
  ///
  /// ```http
  /// GET /api/group/get/owner/id/1
  ///
  /// {
  ///  "data": {
  ///    "result": 1
  ///  },
  ///  "status": 200,
  ///  "success": true,
  ///  "message": "Group owner found"
  /// },
  @Route.get('/get/owner/id/<id>')
  Future<Response> getGroupOwner(Request request, String id) async =>
      utils.checkedRoute(
          (final Request request, Map<String, dynamic> args) async {
        final int? groupId = int.tryParse(args['groupId'] ?? '');

        return Response.ok(
            jsonEncode(await groupService.getGroupOwner(groupId)),
            headers: {'Content-Type': 'application/json'});
      }, request, args: {'groupId': id});
}
