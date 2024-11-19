import 'dart:io';

import 'package:backend/config/config.dart';
import 'package:backend/middleware/api_token_manager.dart';
import 'package:backend/middleware/auth_manager.dart';
import 'package:backend/middleware/group_invitation_manager.dart';
import 'package:backend/middleware/password_utils.dart';
import 'package:backend/middleware/registration_manager.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/server/base_router.dart';
import 'package:backend/util/group_cleaner.dart';
import 'package:backend/util/job_scheduler.dart';
import 'package:backend/util/user_cleaner.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'test_config.dart';
import 'test_utils.dart';

void main() async {
  late AppDatabase db;
  late HttpServer server;

  final Config config = TestConfig();

  final PasswordUtils passwordUtils = PasswordUtils(config);
  final AuthManager authTokenManager = AuthManager(config);
  final ApiTokenManger apiTokenManager = ApiTokenManger(config);
  final RegistrationManager registrationManager = RegistrationManager(config);
  final GroupInvitationManager groupInvitationManager =
      GroupInvitationManager(config);

  late int adminId = 0;
  late int userId = 0;
  late int groupId = 0;

  setUp(() async {
    db = AppDatabase.fromExecutor(NativeDatabase.memory());

    final Routes service = Routes(db, config);
    final Router router = service.router;
    final JobScheduler jobScheduler = JobScheduler();

    final String adminSalt = await passwordUtils.generateSalt();
    final String userSalt = await passwordUtils.generateSalt();

    final String adminPassword =
        await passwordUtils.hashPassword('password1', adminSalt);
    final String userPassword =
        await passwordUtils.hashPassword('password2', userSalt);

    adminId = await db.userDao.insertUser(
        UsersCompanion.insert(
            name: 'Test Admin',
            email: 'admin@uni-bremen.de',
            active: Value(true),
            role: Value(Role.ADMIN)),
        adminPassword,
        adminSalt);

    userId = await db.userDao.insertUser(
        UsersCompanion.insert(
            name: 'Test User',
            email: 'user@uni-bremen.de',
            active: Value(true),
            role: Value(Role.USER)),
        userPassword,
        userSalt);

    groupId = await db.userGroupDao
        .createGroup(userId, 'Test Group', 'This is a test group');

    jobScheduler.addJob(UserCleaner(
        Duration(minutes: config.INACTIVE_USER_MINUTES), true, db, config));
    jobScheduler.addJob(GroupCleaner(
        Duration(days: config.INVITATION_EXPIRATION_DAYS), true, db, config));
    jobScheduler.startAll();

    server = await io.serve(router.call, config.API_HOST, config.API_PORT);
  });

  tearDown(() async {
    await db.close();
    await server.close(force: true);
  });

  // Security Routes

  test('POST /api/auth/login - valid credentials', () async {
    final http.Response response = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/login',
        body: {'email': 'user@uni-bremen.de', 'password': 'password2'},
        expectedStatus: 200,
        expectedMessage: 'Authenticated');

    final Map<String, dynamic> data =
        getResponseData(response, requiredFields: ['token']);

    final String jwt = data['token'] as String;

    expect(response.statusCode, 200);
    expect(jwt.isNotEmpty, true);
    expect(authTokenManager.isValidToken(jwt), true);
    expect(await authTokenManager.getUserId(jwt), userId);
  });

  test('POST /api/auth/login - invalid email', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/login',
        body: {'email': 'some@uni-bremen.de', 'password': 'password2'},
        expectedStatus: 403,
        expectedMessage: 'Invalid email or password');
  });

  test('POST /api/auth/login - invalid password', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/login',
        body: {'email': 'user@uni-bremen.de', 'password': 'password3'},
        expectedStatus: 403,
        expectedMessage: 'Invalid email or password');
  });

  test('POST /api/auth/register - new user', () async {
    final http.Response response = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {
          'email': 'user2@uni-bremen.de',
          'password': 'password3',
          'name': 'Test User 2'
        },
        expectedStatus: 200,
        expectedMessage: 'User created, please check email for activation.');

    final Map<String, dynamic> data =
        getResponseData(response, requiredFields: ['result']);

    final User? user = await db.userDao.getUserByEmail('user2@uni-bremen.de');

    if (user == null) {
      fail('User not found');
    }

    expect(user.active, false);
    expect(data['result'] is int, true);
    expect(data['result'], user.id);
  });

  test('POST /api/auth/register - password is hashed', () async {
    final http.Response response = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {
          'email': 'user2@uni-bremen.de',
          'password': 'password3',
          'name': 'Test User 2'
        },
        expectedStatus: 200,
        expectedMessage: 'User created, please check email for activation.');

    final Map<String, dynamic> data =
        getResponseData(response, requiredFields: ['result']);

    final String? salt = await db.userDao.getSaltById(data['result']);
    if (salt == null) {
      fail('Salt not found');
    }

    final String hashedPassword =
        await passwordUtils.hashPassword('password3', salt);

    final bool result = await db.userDao.verifyLogin(
      'user2@uni-bremen.de',
      hashedPassword,
    );

    expect(result, true);
  });

  test('POST /api/auth/register - existing user', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {
          'email': 'user@uni-bremen.de',
          'password': 'password2',
          'name': 'Test User'
        },
        expectedStatus: 400,
        expectedMessage: 'User already exists');
  });

  test('POST /api/auth/register - missing fields', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {'email': 'user2@uni-bremen.de', 'password': 'password3'},
        expectedStatus: 400,
        expectedMessage: 'Invalid name');
  });

  test('POST /api/auth/register - invalid email', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {
          'email': 'user2uni-bremen.de',
          'password': 'password3',
          'name': 'Test User 2'
        },
        expectedStatus: 400,
        expectedMessage: 'Invalid email');
  });

  test('POST /api/auth/register - empty password', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/register',
        body: {
          'email': 'user2@uni-bremen.de',
          'password': '',
          'name': 'Test User 2'
        },
        expectedStatus: 400,
        expectedMessage: 'Invalid password');
  });

  test('GET /api/auth/verify_registration', () async {
    final UsersCompanion user = UsersCompanion.insert(
        name: 'Test User 2',
        email: 'user2@uni-bremen.de',
        active: Value(false),
        role: Value(Role.USER));

    final int userId = await db.userDao
        .insertUser(user, 'password3', await passwordUtils.generateSalt());

    final String token =
        registrationManager.generateToken(userId, 'user2@uni-bremen.de');
    final String path = '/api/auth/verify_registration/$token';

    await callEndPoint(
        method: Method.GET,
        config: config,
        path: path,
        expectedStatus: 200,
        expectedMessage: 'User activated');
  });
  test('POST /api/auth/genereate_api_token - user is requester', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/generate_api_token',
        body: {'email': 'user@uni-bremen.de', 'days': 1},
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: false,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Token sent to email');
  });

  test('POST /api/auth/generate_api_token - user is not requester', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/generate_api_token',
        body: {'email': 'admin@uni-bremen.de', 'days': 1},
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: false,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'Unauthorized: Requester is not the user');
  });

  // User Routes

  test('GET /api/user/get/<id> - user present', () async {
    final http.Response response = await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/id/$userId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User found');

    final Map<String, dynamic> data = getResponseData(response,
        requiredFields: ['id', 'name', 'email', 'role', 'active']);

    expect(data['id'], userId);
    expect(data['name'], 'Test User');
    expect(data['email'], 'user@uni-bremen.de');
    expect(data['active'], true);
  });

  test('GET /api/user/get/<id> - user not found', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/id/999',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 404,
        expectedMessage: 'User not found');
  });

  test('GET /api/user/get/email/<email> - user present', () async {
    final http.Response response = await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/email/admin@uni-bremen.de',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User found');

    final Map<String, dynamic> data = getResponseData(response,
        requiredFields: ['id', 'name', 'email', 'role', 'active']);

    expect(data['id'], adminId);
    expect(data['name'], 'Test Admin');
    expect(data['email'], 'admin@uni-bremen.de');
    expect(data['active'], true);
  });

  test('GET /api/user/get/email/<email> - user not found', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/email/admin2@uni-bremen.de',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 404,
        expectedMessage: 'User not found');
  });

  test('GET /api/user/get/email/<email> - different api user', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/email/admin@uni-bremen.de',
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User found');
  });

  test('GET /api/user/get/id/<id>/groups/<page>/<pageSize> - with groups',
      () async {
    // Make sure the user is a group member.
    final List<User> users =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 1);
    expect(users[0].id, userId);

    final http.Response response = await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/id/$userId/groups/0/16',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Operation succeeded');

    final Map<String, dynamic> data =
        getResponseData(response, requiredFields: ['result']);

    expect(data['result'] is List, true);
    expect(data['result'].length, 1);
    expect(data['result'][0]['id'], groupId);
    expect(data['result'][0]['name'], 'Test Group');
    expect(data['result'][0]['description'], 'This is a test group');
  });

  test('POST /api/user/update/name - As same user', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/name',
        body: {'userId': userId, 'name': 'Test User 2'},
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Name updated');
  });

  test('POST /api/user/update/name - As different user', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
          active: Value(true),
          role: Value(Role.USER),
        ),
        'password3',
        await passwordUtils.generateSalt());

    if (await db.userDao.getUserById(userId) == null) {
      fail('User not found');
    }

    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/name',
        body: {'userId': newUserId, 'name': 'Test User 3'},
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'Unauthorized access');
  });

  test('POST /api/user/update/name - As admin', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/name',
        body: {'userId': userId, 'name': 'Test User 2'},
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Name updated');
  });

  test('POST /api/user/update/password - As same user correct pw', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/password',
        body: {
          'userId': userId,
          'oldPassword': 'password2',
          'newPassword': 'newPassword'
        },
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Password updated');
  });

  test('POST /api/user/update/password - As same user incorrect pw', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/password',
        body: {
          'userId': userId,
          'oldPassword': 'password3',
          'newPassword': 'newPassword'
        },
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'Unauthorized access');
  });

  test('POST /api/user/update/password - As different user', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
          active: Value(true),
          role: Value(Role.USER),
        ),
        'password3',
        await passwordUtils.generateSalt());

    if (await db.userDao.getUserById(userId) == null) {
      fail('User not found');
    }

    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/password',
        body: {
          'userId': newUserId,
          'oldPassword': 'password2',
          'newPassword': 'newPassword'
        },
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'Unauthorized access');
  });

  test('POST /api/user/update/password - As admin', () async {
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/user/update/password',
        body: {'userId': userId, 'newPassword': 'newPassword'},
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, adminId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Password updated');
  });

  test('POST /api/user/delete/<id> - As same user', () async {
    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/user/delete/id/$userId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User deleted');
  });

  test('POST /api/user/delete/<id> - As different user', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
          active: Value(true),
          role: Value(Role.USER),
        ),
        'password3',
        await passwordUtils.generateSalt());

    if (await db.userDao.getUserById(userId) == null) {
      fail('User not found');
    }

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/user/delete/id/$newUserId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'Unauthorized access');
  });

  test('POST /api/user/delete/<id> - As admin', () async {
    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/user/delete/id/$userId',
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, adminId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User deleted');
  });

  // Group Routes

  test('GET /api/group/get/id/<id> - group present', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/group/get/id/1',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group found');
  });

  test('GET /api/group/get/id/<id> - group not found', () async {
    await callEndPoint(
      method: Method.GET,
      config: config,
      path: '/api/group/get/id/2',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 404,
      expectedMessage: 'Group not found',
    );
  });

  test('GET /api/group/get/name/<name> - group present', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/group/get/name/Test%20Group',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group found');
  });

  test('GET /api/group/get/name/<name> - group not found', () async {
    await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/group/get/name/Nonexistent Group',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 404,
        expectedMessage: 'Group not found');
  });

  // Get all groups from the database with pagination.
  test('GET /api/group/get/all/<page>/<pageSize> - with pagination', () async {
    // Add 32 groups to the database.
    for (int i = 0; i < 32; i++) {
      // First we must create 32 users as owners.
      final int newUserId = await db.userDao.insertUser(
          UsersCompanion.insert(
            email: 'user$i@uni-bremen.de',
            name: 'User $i',
          ),
          'salted_password',
          'some_salt');

      // Then we create a group for each user.
      await db.userGroupDao
          .createGroup(newUserId, 'Group $i', 'Description $i');
    }

    // We should have a total of 33 groups in the database, meaning that at a
    // page size of 16, there should be a total of 3 pages.
    for (int i = 0; i < 3; i++) {
      http.Response response = await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/group/get/all/$i/16',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Groups found',
      );

      final Map<String, dynamic> data = getResponseData(response);
      expect(data['result'] is List, true);
      expect(data['result'].length, i == 2 ? 1 : 16);
    }
  });

  test('GET /api/group/get/id/<id>/members/<page>/<pagesize> - with members',
      () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'New User',
        ),
        'salted_password',
        'some_salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    await callEndPoint(
      method: Method.GET,
      config: config,
      path: '/api/group/get/id/$groupId/members/0/16',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Operation succeeded',
    );

    final List<User> members =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(members.length, 2);
    expect(members[0].id == userId, true);
    expect(members[1].id == newUserId, true);
  });

  // Get all groups by user ID from the database.

  //

  test('POST /api/group/create - valid group', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'New User',
        ),
        'salted_password',
        'some_salt');

    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/group/create',
        body: {'name': 'New Group', 'description': 'This is a new group'},
        apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, newUserId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group created');

    final GroupDetail? group = await db.groupDao.getGroupByName('New Group');

    if (group == null) {
      fail('Group not found');
    }

    expect(group.name, 'New Group');
    expect(group.description, 'This is a new group');
  });

  test('POST /api/group/create - existing group', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/create',
      body: {'name': 'Test Group', 'description': 'This is an existing group'},
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 409,
      expectedMessage: 'Group already exists',
    );
  });

  test('POST /api/group/create - too many groups', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/create',
      body: {'name': 'Test Group 3', 'description': 'This is another group'},
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User has too many groups',
    );
  });

  test('DELETE /api/group/delete - valid group', () async {
    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/$groupId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group deleted');

    // Check that the group does not exist in the database anymore.
    final GroupDetail? group = await db.groupDao.getGroupById(groupId);
    expect(group, null);

    // Check that the UserGroup table entry is also deleted by cascade.
    try {
      await db.userGroupDao.getOwnerByGroupId(groupId);
    } catch (e) {
      expect(e, isA<StateError>());
      expect(e.toString(), 'Bad state: No element');
    }
  });

  test('DELETE /api/group/delete - group with users', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // Ensure that the user is listed as a member of the group.
    final List<User> users =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);
    expect(users[0].id == userId, true);
    expect(users[1].id == newUserId, true);

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/$groupId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group deleted');

    // Check that the group does not exist in the database anymore.
    final GroupDetail? group = await db.groupDao.getGroupById(groupId);
    expect(group, null);

    // Check that the users are no longer listed as members of the group.

    final List<GroupDetail> groupsUser1 =
        await db.userGroupDao.getGroupsByUserId(userId, 1, 16);
    expect(groupsUser1.length, 0);

    final List<GroupDetail> groupsUser2 =
        await db.userGroupDao.getGroupsByUserId(newUserId, 1, 16);
    expect(groupsUser2.length, 0);
  });

  test('DELETE /api/group/delete - no cascade by user deletion', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // Ensure that the user is listed as a member of the group.
    final List<User> users =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/user/delete/id/$newUserId',
        apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, newUserId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User deleted');

    // Check that the group still exists in the database anymore.
    final GroupDetail? group = await db.groupDao.getGroupById(groupId);
    expect(group, (group) => group != null);

    // Check that the user is no longer listed as a member of the group.
    final List<User> usersAfterDeletion =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(usersAfterDeletion.length, 1);
    expect(usersAfterDeletion[0].id == userId, true);
  });

  test('DELETE /api/group/delete - cascade by owner deletion', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // Ensure that the user is listed as a member of the group.
    final List<User> users =
        await db.userGroupDao.getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/user/delete/id/$userId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User deleted');

    // Check that the group does not exist in the database anymore.
    final GroupDetail? group = await db.groupDao.getGroupById(groupId);
    expect(group, null);

    // Check that the users are no longer listed as members of the group.
    final List<GroupDetail> groupsUser2 =
        await db.userGroupDao.getGroupsByUserId(newUserId, 0, 16);
    expect(groupsUser2.length, 0);
  });

  // Delete group not found
  test('DELETE /api/group/delete - group not found', () async {
    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/999',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'User is not the owner of the group');
  });

  // Delete group not owned
  test('DELETE /api/group/delete - group not owned', () async {
    final int newGroupId = await db.userGroupDao
        .createGroup(adminId, 'Test Group 2', 'This is a test group 2');

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/$newGroupId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 403,
        expectedMessage: 'User is not the owner of the group');
  });

  // Delete group as admin
  test('DELETE /api/group/delete - group deleted as admin', () async {
    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/$groupId',
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, adminId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group deleted');
  });

  // Delete group not owned as admin
  test('DELETE /api/group/delete - group not owned as admin', () async {
    final int newGroupId = await db.userGroupDao
        .createGroup(userId, 'Test Group 2', 'This is a test group 2');

    await callEndPoint(
        method: Method.DELETE,
        config: config,
        path: '/api/group/delete/id/$newGroupId',
        apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, adminId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'Group deleted');
  });

  // Update group name - as owner
  test('POST /api/group/update/name - as owner', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/name',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': groupId,
        'name': 'New Group Name',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Group updated',
    );
  });

  test('POST /api/group/update/name - group not found', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/name',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': 999,
        'name': 'New Group Name',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'User is not the owner of the group',
    );
  });

  // Update group name - as different user
  test('POST /api/group/update/name - as different user', () async {
    final int newGroupId = await db.userGroupDao
        .createGroup(adminId, 'Test Group 2', 'This is a test group 2');

    // Ensure that the group is created.
    final GroupDetail? group = await db.groupDao.getGroupById(newGroupId);
    expect(group, (group) => group != null);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/name',
      apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': newGroupId,
        'name': 'New Group Name',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'User is not the owner of the group',
    );
  });

  // Update group name - as admin
  test('POST /api/group/update/name - as admin', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/name',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {
        'id': groupId,
        'name': 'New Group Name',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Group updated',
    );
  });

  // Update group description - as owner
  test('POST /api/group/update/description - as owner', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/description',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': groupId,
        'description': 'New Group Description',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Group updated',
    );
  });

  test('POST /api/group/update/description - group does not exist', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/description',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': 999,
        'description': 'New Group Description',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'User is not the owner of the group',
    );
  });

  // Update group description - as different user
  test('POST /api/group/update/description - as different user', () async {
    final int newGroupId = await db.userGroupDao
        .createGroup(adminId, 'Test Group 2', 'This is a test group 2');

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/description',
      apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'id': newGroupId,
        'description': 'New Group Description',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'User is not the owner of the group',
    );
  });

  // Update group description - as admin
  test('POST /api/group/update/description - as admin', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/update/description',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {
        'id': groupId,
        'description': 'New Group Description',
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Group updated',
    );
  });

  // Invite user to group - as owner
  test('POST /api/group/invite - as owner', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    // Ensure that the user is created.
    final User? user = await db.userDao.getUserById(newUserId);
    expect(user, (user) => user != null);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': newUserId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Invitation sent',
    );
  });

  // Invite user to group - as different user
  test('POST /api/group/invite - as different user', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    // Ensure that the user is created.
    final User? user = await db.userDao.getUserById(newUserId);
    expect(user, (user) => user != null);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, newUserId),
      body: {
        'userId': adminId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'Requester has no permission to invite user',
    );
  });

  // Invite user to group - as admin
  test('POST /api/group/invite - as admin', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'Test User 2',
        ),
        'salted_password',
        'some_salt');

    // Ensure that the user is created.
    final User? user = await db.userDao.getUserById(newUserId);
    expect(user, (user) => user != null);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {
        'userId': newUserId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Invitation sent',
    );
  });

  // Invite user to group - user not found
  test('POST /api/group/invite - user not found', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': 999,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User not found',
    );
  });

  // Invite user to group - group not found
  test('POST /api/group/invite - group not found', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': 999,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'Requester has no permission to invite user',
    );
  });

  test('POST /api/group/invite - invitee is owner', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': userId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'Owner cannot invite themselves to the group',
    );
  });

  // Invite user to group - user is already invited
  test('POST /api/group/invite - user is already invited', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'Invitation sent',
    );

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User is already invited to the group',
    );
  });

  test('POST /api/group/invite - user is already member', () async {
    await UserGroupDao(db).addUserToGroup(adminId, groupId, isTentative: false);

    // Ensure that the user is listed as a member of the group.
    final List<User> users =
        await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);
    expect(users[0].id == userId, true);
    expect(users[1].id == adminId, true);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User is already a member of the group',
    );
  });

  test('POST /api/group/invite - group not found', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': 999,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'Requester has no permission to invite user',
    );
  });

  // Accept invitation - as invited user
  test('POST /api/group/accept<token> - as invited user', () async {
    final String token = groupInvitationManager.generateToken(adminId, groupId);

    // Persist the invitation token in the database.
    await db.userGroupDao.addUserToGroup(adminId, groupId);

    await callEndPoint(
      method: Method.GET,
      config: config,
      path: '/api/group/accept/$token',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User added to group',
    );

    // Ensure that the user is listed as a member of the group.
    final List<User> users =
        await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);
    expect(users[0].id == userId, true);
    expect(users[1].id == adminId, true);

    // Ensure that the user is now a permanent member of the group.
    final bool isTentative =
        await UserGroupDao(db).isTentativeMemberOfGroup(adminId, groupId);

    expect(isTentative, false);
  });

  test('POST /api/group/accept<token> - accept twice', () async {
    final String token = groupInvitationManager.generateToken(adminId, groupId);

    // Persist the invitation token in the database.
    await db.userGroupDao.addUserToGroup(adminId, groupId);

    await callEndPoint(
      method: Method.GET,
      config: config,
      path: '/api/group/accept/$token',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User added to group',
    );

    await callEndPoint(
      method: Method.GET,
      config: config,
      path: '/api/group/accept/$token',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User is already a member of the group',
    );
  });

  // Add too many users to group
  test('POST /api/group/invite - too many users', () async {
    for (int i = 0; i < config.MAX_GROUP_MEMBERS; i++) {
      final int newUserId = await db.userDao.insertUser(
          UsersCompanion.insert(
            name: 'user$i',
            email: 'user$i@uni-bremen.de',
          ),
          'password',
          'salt');

      await db.userGroupDao.addUserToGroup(newUserId, groupId);
    }

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/invite',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': adminId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'Group is full',
    );
  });

  // Remove a user from a group - as owner
  test('POST /api/group/remove_user - as owner', () async {
    // Add a user to the group.
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(email: 'user2@uni-bremen.de', name: 'New User'),
        'password',
        'salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // There should be two users in the group.
    List<User> users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': newUserId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User removed from group',
    );

    // Ensure that the user is no longer listed as a member of the group.
    users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 1);
  });

  test('POST /api/group/remove_user - user does not exist', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': 999,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User is not a member of the group',
    );

    // Ensure that the user is no longer listed as a member of the group.
    final List<User> users =
        await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 1);
  });

  test('POST /api/group/remove_user - group does not exist', () async {
    // Add a user to the group.
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(email: 'user2@uni-bremen.de', name: 'New User'),
        'password',
        'salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // There should be two users in the group.
    List<User> users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': newUserId,
        'groupId': 999,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'Requester has no permission to remove user',
    );

    // Ensure that the user is no longer listed as a member of the group.
    users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);
  });

  // Remove a user from a group - as different user
  test('POST /api/group/remove_user - as different user', () async {
    // Add a user to the group.
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(email: 'user2@uni-bremen.de', name: 'New User'),
        'password',
        'salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user2@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, newUserId),
      body: {
        'userId': userId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 403,
      expectedMessage: 'Requester has no permission to remove user',
    );
  });

  // Remove a user from a group - as admin
  test('POST /api/group/remove_user - as admin', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {
        'userId': userId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User removed from group',
    );

    // Ensure that the user is no longer listed as a member of the group.
    final List<User> users =
        await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 0);
  });

  // Remove a user from a group - user not found
  test('POST /api/group/remove - user exists but is not member', () async {
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(email: 'user2@uni-bremen.de', name: 'New User'),
        'password',
        'salt');

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': newUserId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'User is not a member of the group',
    );
  });

  test('POST /api/group/remove_user - user is owner', () async {
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': userId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 400,
      expectedMessage: 'Owner cannot remove themselves from the group',
    );
  });

  // Remove last user from group - group must be deleted all members booted off
  test('POST /api/group/remove_user - remove last user from group', () async {
    // Add a user to the group.
    final int newUserId = await db.userDao.insertUser(
        UsersCompanion.insert(
          email: 'user2@uni-bremen.de',
          name: 'New User',
        ),
        'password',
        'salt');

    await db.userGroupDao
        .addUserToGroup(newUserId, groupId, isTentative: false);

    // There should be two users in the group.
    List<User> users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 2);

    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, userId),
      body: {
        'userId': newUserId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User removed from group',
    );

    // Ensure that the user is no longer listed as a member of the group.
    users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 1);

    // Remove the last user from the group.
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {
        'userId': userId,
        'groupId': groupId,
      },
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User removed from group',
    );

    // Ensure that the group is deleted.
    final GroupDetail? group = await db.groupDao.getGroupById(groupId);
    expect(group, (group) => group == null);

    // Ensure that all members are booted off.
    users = await UserGroupDao(db).getUsersByGroupId(groupId, 0, 16);
    expect(users.length, 0);

    // Check for the users that there are no groups left.
    final List<GroupDetail> groupsUser1 =
        await UserGroupDao(db).getGroupsByUserId(userId, 1, 16);
    expect(groupsUser1.length, 0);

    final List<GroupDetail> groupsUser2 =
        await UserGroupDao(db).getGroupsByUserId(newUserId, 1, 16);
    expect(groupsUser2.length, 0);
  });

  // Delete own group as admin
  test('POST /api/group/remove_user - leave group as admin', () async {
    // Create a new group as admin
    final int newGroupId = await db.userGroupDao
        .createGroup(adminId, "New Group", "New Group Description.");

    // Ensure that the group is created
    GroupDetail? group = await db.groupDao.getGroupById(newGroupId);
    expect(group, (group) => group != null);

    // Delete the group as admin
    await callEndPoint(
      method: Method.POST,
      config: config,
      path: '/api/group/remove_user',
      apiToken: apiTokenManager.generateToken('admin@uni-bremen.de'),
      authToken: getAuthToken(authTokenManager, adminId),
      body: {'groupId': newGroupId, 'userId': adminId},
      expectApiAuthorized: true,
      expectAuthenticated: true,
      expectedStatus: 200,
      expectedMessage: 'User removed from group',
    );

    // Ensure that the group is deleted
    group = await db.groupDao.getGroupById(newGroupId);
    expect(group, (group) => group == null);

    // Ensure that the user is no longer listed as a member of the group.
    final List<User> users =
        await UserGroupDao(db).getUsersByGroupId(newGroupId, 0, 16);
    expect(users.length, 0);

    // Check for the user that there are no groups left.
    final List<GroupDetail> groupsUser1 =
        await UserGroupDao(db).getGroupsByUserId(adminId, 1, 16);
    expect(groupsUser1.length, 0);
  });

  // Check refesh token functionality
  test('POST /api/auth/refresh - refresh token', () async {
    final http.Response authResponse = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/login',
        body: {'email': 'user@uni-bremen.de', 'password': 'password2'},
        expectedStatus: 200,
        expectedMessage: 'Authenticated');

    final Map<String, dynamic> authData =
        getResponseData(authResponse, requiredFields: ['token', 'refresh']);

    final String oldToken = authData['token'] as String;
    final String oldRefresh = authData['refresh'] as String;

    // Wait for at least 1 second to ensure that the token is different
    await Future.delayed(const Duration(seconds: 1));

    final http.Response refreshResponse = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/refresh',
        body: {'token': oldToken, 'refresh': oldRefresh},
        expectedStatus: 200,
        expectedMessage: 'Authenticated');

    final Map<String, dynamic> refreshData =
        getResponseData(refreshResponse, requiredFields: ['token', 'refresh']);

    final String newToken = refreshData['token'] as String;
    final String newRefresh = refreshData['refresh'] as String;

    expect(newToken != oldToken, true);
    expect(newRefresh != oldRefresh, true);

    // Check if the new token is valid
    final http.Response response = await callEndPoint(
        method: Method.GET,
        config: config,
        path: '/api/user/get/id/$userId',
        apiToken: apiTokenManager.generateToken('user@uni-bremen.de'),
        authToken: getAuthToken(authTokenManager, userId),
        expectApiAuthorized: true,
        expectAuthenticated: true,
        expectedStatus: 200,
        expectedMessage: 'User found');

    getResponseData(response,
        requiredFields: ['id', 'name', 'email', 'role', 'active']);

    // Check if the refresh token is valid
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/refresh',
        body: {'token': newToken, 'refresh': newRefresh},
        expectedStatus: 200,
        expectedMessage: 'Authenticated');
  });

  // Check the logout functionality
  test('POST /api/auth/logout - logout', () async {
    final http.Response authResponse = await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/login',
        body: {'email': 'user@uni-bremen.de', 'password': 'password2'},
        expectedStatus: 200,
        expectedMessage: 'Authenticated');

    final Map<String, dynamic> authData =
        getResponseData(authResponse, requiredFields: ['token', 'refresh']);

    final String token = authData['token'] as String;
    final String refresh = authData['refresh'] as String;

    // Invalidate the token
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/logout',
        body: {'refresh': refresh},
        expectedStatus: 200,
        expectedMessage: 'Token revoked');

    // Ensure the refresh token is invalid
    await callEndPoint(
        method: Method.POST,
        config: config,
        path: '/api/auth/refresh',
        body: {'refresh': refresh},
        expectedStatus: 403,
        expectedMessage: 'Invalid refresh token');
  });
}
