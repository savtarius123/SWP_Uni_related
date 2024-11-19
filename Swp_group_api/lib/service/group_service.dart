import 'package:backend/config/config.dart';
import 'package:backend/exception/service_exception.dart';
import 'package:backend/middleware/group_invitation_manager.dart';
import 'package:backend/service/service_utils.dart';
import 'package:backend/util/mailer.dart';
import 'package:backend/util/validators.dart';

import '../model/src/database.dart';

class GroupService {
  late final AppDatabase db;
  late final Config config;
  late final Validators validators;
  late final GroupDao _groupDao;
  late final UserGroupDao _userGroupDao;
  late final UserDao _userDao;
  late final GroupInvitationManager _groupInvitationGenerator;
  late final Mailer _mailer;

  GroupService(this.db, this.config)
      : validators = Validators(config),
        _groupDao = db.groupDao,
        _userGroupDao = db.userGroupDao,
        _userDao = db.userDao,
        _mailer = Mailer(config) {
    _groupInvitationGenerator = GroupInvitationManager(config);
  }

  /// Retrieve a single group by its ID from the database. If the ID is
  /// malformed or the group does not exist, an error is returned. Otherwise,
  /// the group data is returned.
  ///
  /// @param groupId The ID of the group to retrieve.
  ///
  /// @return A map containing the group data.
  ///
  /// @throws [ServiceException] If the group ID is invalid or the group does
  /// not exist.
  Future<Map<String, dynamic>> getGroupById(final int? groupId) {
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    return wrapJsonCall(_groupDao.getGroupById,
        args: [groupId],
        test: (result) => result != null,
        errorStatus: 404,
        errorMessage: 'Group not found',
        successMessage: 'Group found');
  }

  /// Retrieves a group by its name. Returns a [Future] that completes with a
  /// [Map] containing the group information. The [name] parameter specifies the
  /// name of the group to retrieve.
  ///
  /// @param name The name of the group to retrieve.
  ///
  /// @return A [Future] that completes with a [Map] containing the group
  ///
  /// @throws [ServiceException] If the group name is invalid or the group does
  /// not exist.
  Future<Map<String, dynamic>> getGroupByName(final String? name) {
    simpleTest(validators.isValidGroupName(name), parameterName: 'group name');

    return wrapJsonCall<GroupDetail?>(_groupDao.getGroupByName,
        args: [name],
        test: (result) => result != null,
        errorStatus: 404,
        errorMessage: 'Group not found',
        successMessage: 'Group found');
  }

  Future<Map<String, dynamic>> getAllGroups(
      final int? page, final int? pageSize) {
    simpleTest(validators.isValidPage(page), parameterName: 'page');
    simpleTest(validators.isValidPageSize(pageSize),
        parameterName: 'page size');

    return wrapJsonCall(_groupDao.getAllGroups,
        args: [page, pageSize],
        test: (result) => result != null,
        errorStatus: 404,
        errorMessage: 'No groups found',
        successMessage: 'Groups found');
  }

  /// Update a group's name unconditionally. If the requester is not the owner of
  /// the group, an admin, or the group does not exist, a [ServiceException] is
  /// thrown. Otherwise, the group name is updated and a success message is
  /// returned.
  ///
  /// @param requesterId The ID of the user making the request.
  ///
  /// @param groupId The ID of the group to update.
  ///
  /// @param groupName The new name of the group.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the requester is not the owner of the group,
  /// an admin, or the group does not exist.
  Future<Map<String, dynamic>> updateGroupName(final int? requesterId,
      final int? groupId, final String? groupName) async {
    simpleTest(validators.isValidUserId(requesterId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');
    simpleTest(validators.isValidGroupName(groupName),
        parameterName: 'group name');

    bool isAllowed = await makeDatabaseCall<bool>(_userGroupDao.ownsGroup,
            args: [requesterId, groupId]) ??
        false;

    if (!isAllowed) {
      isAllowed =
          await makeDatabaseCall<bool>(_userDao.isAdmin, args: [requesterId]) ??
              false;
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('User is not the owner of the group', status: 403),
          HttpErrorStatus.forbidden);
    }

    final GroupDetail? group = await makeDatabaseCall<GroupDetail>(
        _groupDao.getGroupById,
        args: [groupId]);
    if (group == null) {
      throw ServiceException(makeErrorResponse('Group not found', status: 404),
          HttpErrorStatus.notFound);
    }

    final GroupDetailsCompanion companion =
        group.copyWith(name: groupName).toCompanion(false);

    // Update the group name in the database.
    return wrapJsonCall<bool>(_groupDao.updateGroup,
        args: [companion],
        test: (result) => result != null && result,
        omitData: true,
        successMessage: 'Group updated',
        errorMessage: 'Group not found');
  }

  /// Update a group's description unconditionally with the given parameters. If
  /// the requester is not the owner of the group, an admin, or the group does
  /// not exist, a [ServiceException] is thrown. Otherwise, the group
  /// description is updated and a success message is returned.
  ///
  /// @param requesterId The ID of the user making the request.
  ///
  /// @param groupId The ID of the group to update.
  ///
  /// @param groupDescription The new description of the group.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the requester is not the owner of the group,
  /// an admin, or the group does not exist.
  Future<Map<String, dynamic>> updateGroupDescription(final int? requesterId,
      final int? groupId, final String? groupDescription) async {
    simpleTest(validators.isValidUserId(requesterId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');
    simpleTest(validators.isValidGroupDescription(groupDescription),
        parameterName: 'group description');

    bool isAllowed = await makeDatabaseCall<bool>(_userGroupDao.ownsGroup,
            args: [requesterId, groupId]) ??
        false;

    if (!isAllowed) {
      isAllowed =
          await makeDatabaseCall<bool>(_userDao.isAdmin, args: [requesterId]) ??
              false;
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('User is not the owner of the group', status: 403),
          HttpErrorStatus.forbidden);
    }

    final GroupDetail? group = await makeDatabaseCall<GroupDetail>(
        _groupDao.getGroupById,
        args: [groupId]);
    if (group == null) {
      throw ServiceException(makeErrorResponse('Group not found', status: 404),
          HttpErrorStatus.notFound);
    }

    final GroupDetailsCompanion companion =
        group.copyWith(description: groupDescription).toCompanion(false);

    // Update the group name in the database.
    return wrapJsonCall<bool>(_groupDao.updateGroup,
        args: [companion],
        test: (result) => result != null && result,
        omitData: true,
        successMessage: 'Group updated',
        errorMessage: 'Group not found');
  }

  /// Creates a new group. Contrary to the name, there is no method to create a
  /// group without a user, due to the fact, that a group must have at least
  /// one member, the owner. If the requester ID is invalid, the group name is
  /// invalid, the group description is invalid, the group already exists, or
  /// the user has too many groups, a [ServiceException] is thrown. Otherwise,
  /// the group is created and a success message is returned. The number of
  /// allowed groups per user is defined in the configuration.
  ///
  /// @param requesterId The ID of the user creating the group.
  ///
  /// @param groupName The name of the group to create.
  ///
  /// @param groupDescription The description of the group to create.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the requester ID is invalid, the group name
  /// is invalid, the group description is invalid, the group already exists, or
  /// the user has too many groups.
  Future<Map<String, dynamic>> createGroupWithUser(final int? requesterId,
      final String? groupName, final String? groupDescription) async {
    simpleTest(validators.isValidUserId(requesterId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupName(groupName),
        parameterName: 'group name');
    simpleTest(validators.isValidGroupDescription(groupDescription),
        parameterName: 'group description');

    // Check if the group already exists.
    final GroupDetail? group = await makeDatabaseCall<GroupDetail>(
        _groupDao.getGroupByName,
        args: [groupName]);
    if (group != null) {
      throw ServiceException(
          makeErrorResponse('Group already exists', status: 409),
          HttpErrorStatus.conflict);
    }

    // Check if the user has too many groups.
    final int groupCount = await makeDatabaseCall<int>(
            _userGroupDao.getGroupCountOwnedByUserId,
            args: [requesterId]) ??
        0;
    if (groupCount >= config.MAX_GROUP_PER_USER) {
      throw ServiceException(
          makeErrorResponse('User has too many groups', status: 400),
          HttpErrorStatus.badRequest);
    }

    return wrapJsonCall<int>(_userGroupDao.createGroup,
        args: [requesterId, groupName, groupDescription],
        test: (result) => result != null && result > 0,
        errorStatus: 500,
        successMessage: 'Group created',
        errorMessage: 'Could not create group');
  }

  Future<Map<String, dynamic>> deleteGroup(
      final int? requesterId, final int? groupId) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    bool isAllowed = await makeDatabaseCall<bool>(_userGroupDao.ownsGroup,
            args: [requesterId, groupId]) ??
        false;

    if (!isAllowed) {
      isAllowed =
          await makeDatabaseCall<bool>(_userDao.isAdmin, args: [requesterId]) ??
              false;
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('User is not the owner of the group', status: 403),
          HttpErrorStatus.forbidden);
    }

    return wrapJsonCall<bool>(_groupDao.deleteGroup,
        args: [groupId],
        successMessage: 'Group deleted',
        errorStatus: 404,
        omitData: true,
        test: (result) => result != null && result,
        errorMessage: 'Group not found',
        allowList: ['result']);
  }

  /// Removes a user from a group. If the requester ID is invalid, the user ID
  /// is invalid, the group ID is invalid, the requester is the owner of the
  /// group, the requester is an admin, the user is not a member of the group,
  /// or the user is the owner of the group, a [ServiceException] is thrown.
  ///
  /// @param requesterId The ID of the user making the request.
  ///
  /// @param userId The ID of the user to remove from the group.
  ///
  /// @param groupId The ID of the group to remove the user from.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the requester ID is invalid, the user ID is
  /// invalid, the group ID is invalid, the requester is the owner of the group,
  /// the requester is an admin, the user is not a member of the group, or the
  /// user is the owner of the group.
  Future<Map<String, dynamic>> removeUserFromGroup(
      final int? requesterId, final int? userId, final int? groupId) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    bool isAdmin =
        await makeDatabaseCall<bool>(_userDao.isAdmin, args: [requesterId]) ??
            false;

    bool ownsGroup = await makeDatabaseCall<bool>(_userGroupDao.ownsGroup,
            args: [requesterId, groupId]) ??
        false;

    if (!isAdmin && ownsGroup && requesterId == userId) {
      throw ServiceException(
          makeErrorResponse('Owner cannot remove themselves from the group',
              status: 400),
          HttpErrorStatus.badRequest);
    }

    if (!isAdmin && !ownsGroup && requesterId != userId) {
      throw ServiceException(
          makeErrorResponse('Requester has no permission to remove user',
              status: 403),
          HttpErrorStatus.forbidden);
    }

    // Check if the user is a member of the group.
    final bool isMember = await makeDatabaseCall<bool>(
            _userGroupDao.isMemberOfGroup,
            args: [userId, groupId]) ??
        false;
    if (!isMember) {
      throw ServiceException(
          makeErrorResponse('User is not a member of the group', status: 400),
          HttpErrorStatus.badRequest);
    }

    return wrapJsonCall<bool>(_userGroupDao.removeUserFromGroup,
        args: [userId, groupId],
        test: (result) => result != null && result,
        errorStatus: 404,
        omitData: true,
        successMessage: 'User removed from group',
        errorMessage: 'User or group not found');
  }

  /// Retrieve all users in a group. If the group ID is malformed, a
  /// [ServiceException] is thrown. Otherwise, the user data is returned.
  ///
  /// @param groupId The ID of the group to retrieve users from.
  ///
  /// @param page The page number to retrieve.
  ///
  /// @param pageSize The number of users to retrieve per page.
  ///
  /// @return A map containing a list of users.
  ///
  /// @throws [ServiceException] If the group ID is invalid.
  ///
  /// @see [validators.isValidGroupId]
  Future<Map<String, dynamic>> getUsersInGroup(
      final int? groupId, final int? page, final int? pageSize) async {
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    return wrapJsonCall<List<User>>(_userGroupDao.getUsersByGroupId,
        args: [groupId, page, pageSize]);
  }

  /// Get all groups for a user. If the user ID is malformed, an error is
  /// returned. Otherwise, the group data is returned.
  ///
  /// @param userId The ID of the user to retrieve groups for.
  ///
  /// @param page The page number to retrieve.
  ///
  /// @param pageSize The number of groups to retrieve per page.
  ///
  /// @return A map containing a list of groups.
  ///
  /// @throws [ServiceException] If the user ID is invalid or the user does not
  /// exist.
  Future<Map<String, dynamic>> getGroupsByUser(
      final int? userId, final int? page, final int? pageSize) async {
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');

    final result = await wrapJsonCall<List<GroupDetail>>(
        _userGroupDao.getGroupsByUserId,
        args: [userId, page, pageSize]);

    return result;
  }

  /// Creates and sends out an invitation to a user to join a group. The
  /// requester must be the owner of the group or an admin. The user must not
  /// already be a member of the group or have a pending invitation. The group
  /// must not be full. The user is added to the group as a tentative member,
  /// which are counted towards the group size. The user is sent an email with
  /// the invitation token. To accept the invitation, the [acceptInvitation]
  /// method must be called with the token.
  ///
  /// @param requesterId The ID of the user making the request.
  ///
  /// @param userId The ID of the user to invite.
  ///
  /// @param groupId The ID of the group to invite the user to.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the requester has no permission to invite
  /// the user, the user is already a member of the group, the user is already
  /// invited to the group, the group is full, the group does not exist, or the
  /// user does not exist.
  Future<Map<String, dynamic>> createInvitation(
      final int? requesterId, final int? userId, final int? groupId) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    if (requesterId == userId) {
      throw ServiceException(
          makeErrorResponse('Owner cannot invite themselves to the group',
              status: 400),
          HttpErrorStatus.badRequest);
    }

    // Check if the invitee is already a member of the group.
    final bool isMember = await makeDatabaseCall<bool>(
            _userGroupDao.isMemberOfGroup,
            args: [userId, groupId]) ??
        false;

    if (isMember) {
      throw ServiceException(
          makeErrorResponse('User is already a member of the group',
              status: 400),
          HttpErrorStatus.badRequest);
    }

    final bool isTentative = await makeDatabaseCall<bool>(
            _userGroupDao.isTentativeMemberOfGroup,
            args: [userId, groupId]) ??
        false;

    if (isTentative) {
      throw ServiceException(
          makeErrorResponse('User is already invited to the group',
              status: 400),
          HttpErrorStatus.badRequest);
    }

    bool isAllowed = false;

    isAllowed = await makeDatabaseCall<bool>(_userGroupDao.ownsGroup,
            args: [requesterId, groupId]) ??
        false;

    if (!isAllowed) {
      isAllowed =
          await makeDatabaseCall<bool>(_userDao.isAdmin, args: [requesterId]) ??
              false;
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('Requester has no permission to invite user',
              status: 403),
          HttpErrorStatus.forbidden);
    }

    final User? user =
        await makeDatabaseCall<User>(_userDao.getUserById, args: [userId]);
    if (user == null) {
      throw ServiceException(makeErrorResponse('User not found', status: 404),
          HttpErrorStatus.badRequest);
    }

    final int groupSize = await makeDatabaseCall<int>(
            _userGroupDao.getTentativeGroupSize,
            args: [groupId]) ??
        0;

    // A group size of 0 means the group does not exist, since groups must have
    // at least one member or they are deleted.
    if (groupSize == 0) {
      throw ServiceException(makeErrorResponse('Group not found', status: 404),
          HttpErrorStatus.notFound);
    }

    // Check if the group is full.
    if (groupSize >= config.MAX_GROUP_MEMBERS) {
      throw ServiceException(makeErrorResponse('Group is full', status: 400),
          HttpErrorStatus.badRequest);
    }

    final String token =
        _groupInvitationGenerator.generateToken(groupId!, userId!);
    _mailer.sendEmail(user.email, config.GROUP_INVITATION_SUBJECT,
        config.GROUP_INVITATION_BODY + token);

    // Insert the user into the group as a tentative member.
    await makeDatabaseCall<int>(_userGroupDao.addUserToGroup,
        args: [userId, groupId]);

    return makeSuccessResponse({}, message: 'Invitation sent');
  }

  /// Accepts an invitation to join a group. The invitation token is parsed and
  /// the user is added to the group as a non-tentative member. If the token is
  /// invalid, the user is already a member of the group, or the user is not
  /// invited to the group, a [ServiceException] is thrown.
  ///
  /// @param token The invitation token to accept.
  ///
  /// @return A map containing the success message.
  ///
  /// @throws [ServiceException] If the invitation token is invalid, the user is
  ///
  /// @see [GroupInvitationManager]
  Future<Map<String, dynamic>> acceptInvitation(final String? token) async {
    if (token == null) {
      throw ServiceException(
          makeErrorResponse('Invalid invitation token', status: 400),
          HttpErrorStatus.badRequest);
    }

    final Map<String, dynamic> claim =
        await _groupInvitationGenerator.parseInvitation(token);
    final int groupId = claim['groupId'];
    final int userId = claim['userId'];

    // Check if the user is already a member of the group.
    final bool isMember = await makeDatabaseCall<bool>(
            _userGroupDao.isMemberOfGroup,
            args: [userId, groupId]) ??
        false;

    if (isMember) {
      throw ServiceException(
          makeErrorResponse('User is already a member of the group',
              status: 400),
          HttpErrorStatus.badRequest);
    }

    // Set the user to a non-tentative member of the group.
    return wrapJsonCall<bool>(_userGroupDao.setTentativeStatus,
        args: [userId, groupId, false],
        test: (result) => result == true,
        errorStatus: 404,
        errorMessage: 'User or group not found',
        successMessage: 'User added to group',
        omitData: true);
  }

  Future<Map<String, dynamic>> isGroupOwner(
      final int? userId, final int? groupId) {
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    return wrapJsonCall<bool>(_userGroupDao.ownsGroup,
        args: [userId, groupId],
        test: (result) => result == true,
        errorStatus: 404,
        errorMessage: 'User or group not found',
        successMessage: 'User is the owner of the group');
  }

  Future<Map<String, dynamic>> getGroupOwner(final int? groupId) {
    simpleTest(validators.isValidGroupId(groupId), parameterName: 'group ID');

    return wrapJsonCall<int?>(_userGroupDao.getGroupOwner,
        args: [groupId],
        test: (result) => result != null,
        errorStatus: 404,
        errorMessage: 'Group not found',
        successMessage: 'Group owner found');
  }

  Future<bool> deleteTentativeMembers() {
    return _userGroupDao.deleteTentativeMembers();
  }
}
