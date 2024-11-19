import 'package:backend/config/config.dart';
import 'package:backend/exception/service_exception.dart';
import 'package:backend/middleware/auth_manager.dart';
import 'package:backend/middleware/password_utils.dart';
import 'package:backend/middleware/registration_manager.dart';
import 'package:backend/middleware/reset_token_manager.dart';
import 'package:backend/service/service_utils.dart';
import 'package:backend/util/mailer.dart';
import 'package:backend/util/validators.dart';
import 'package:drift/drift.dart';

import '../model/src/database.dart';

class UserService {
  late final AppDatabase db;
  late final Config config;
  late final Validators validators;
  late final UserDao _userDao;
  late final AuthManager _authManager;
  late final RegistrationManager _regManager;
  late final ResetTokenManager _resetManager;
  late final Mailer _mailer;
  late final PasswordUtils _passwordUtils;

  UserService(this.db, this.config)
      : validators = Validators(config),
        _userDao = db.userDao,
        _authManager = AuthManager(config),
        _regManager = RegistrationManager(config),
        _resetManager = ResetTokenManager(config),
        _mailer = Mailer(config),
        _passwordUtils = PasswordUtils(config);

  /// Get a user by ID from the database. The ID must be a positive integer,
  /// greater than 0. If the user does not exist, a ServiceException is
  /// triggered that contains all further information.
  ///
  /// If the user is found, the data is returned.
  ///
  /// @param id The user ID.
  ///
  /// @returns The user data, a map containing the user's ID, name, email, role,
  /// and active status.
  ///
  /// @throws [ServiceException] If the user ID is invalid, the user does not
  /// exist, or an error occurs.
  Future<Map<String, dynamic>> getUserById(final int? id) {
    simpleTest(validators.isValidUserId(id), parameterName: 'user ID');

    return wrapJsonCall(_userDao.getUserById,
        args: [id],
        test: (result) => result != null,
        allowList: ['id', 'name', 'email', 'role', 'active'],
        errorMessage: 'User not found',
        errorStatus: 404,
        successMessage: 'User found');
  }

  /// Get a user by email from the database. The email must be a valid email
  /// address. If the user does not exist, a ServiceException is triggered that
  /// contains all further information.
  ///
  /// If the user is found, the data is returned.
  ///
  /// @param email The user's email address.
  ///
  /// @returns The user data, a map containing the user's ID, name, email, role,
  /// and active status.
  ///
  /// @throws [ServiceException] If the email is invalid, the user does not
  /// exist or an error occurs.
  Future<Map<String, dynamic>> getUserByEmail(final String? email) {
    simpleTest(validators.isValidEmail(email), parameterName: 'email');

    return wrapJsonCall(_userDao.getUserByEmail,
        args: [email],
        test: (result) => result != null,
        errorStatus: 404,
        allowList: ['id', 'name', 'email', 'role', 'active'],
        errorMessage: 'User not found',
        successMessage: 'User found');
  }

  /// Internal method to create a default admin user. The user is created with
  /// the default admin name, email, and password. If the user already exists,
  /// false is returned. Otherwise, true is returned.
  ///
  /// This method should not be called directly from the API layer, but is
  /// instead meant to be used to populate the database with a default admin
  /// user.
  ///
  /// @returns True if the user was created, otherwise false.
  Future<bool> createDefaultAdmin() async {
    final String salt = await _passwordUtils.generateSalt();
    final String hashedPassword =
        await _passwordUtils.hashPassword(config.DEFAULT_ADMIN_PASSWORD, salt);

    final bool success = await _userDao.insertUser(
            UsersCompanion.insert(
              name: config.DEFAULT_ADMIN_NAME,
              email: config.DEFAULT_ADMIN_EMAIL,
              role: Value(1),
              active: Value(true),
            ),
            hashedPassword,
            salt) >
        0;

    return success;
  }

  /// Updates a user's name in the database. If the requester is not the user
  /// and not an admin or the user does not exist, a [ServiceException] is
  /// thrown. Otherwise, the user's name is updated.
  ///
  /// @param requesterId The ID of the user making the request.
  /// @param userId The ID of the user to update.
  /// @param name The new name for the user.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the requester ID, user ID, or name is
  /// invalid, the user does not exist, or any other error occurs.
  Future<Map<String, dynamic>> updateUserName(
      final int? requesterId, final int? userId, final String? name) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');
    simpleTest(validators.isValidName(name), parameterName: 'name');

    bool isAllowed = false;

    if (requesterId == userId) {
      isAllowed = true;
    }

    if (!isAllowed) {
      isAllowed = await _userDao.isAdmin(requesterId!);
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('Unauthorized access', status: 403),
          HttpErrorStatus.forbidden);
    }

    final User? user =
        await makeDatabaseCall<User>(_userDao.getUserById, args: [userId]);

    if (user == null) {
      return makeErrorResponse('User not found', status: 404);
    }

    final UsersCompanion userCompanion =
        user.copyWith(name: name!).toCompanion(false);

    return wrapJsonCall<bool>(_userDao.updateUser,
        args: [userCompanion],
        test: (result) => result != null && result,
        omitData: true,
        errorStatus: 500,
        errorMessage: 'Cannot update user',
        successMessage: 'Name updated');
  }

  /// Updates a user's password in the database. If the requester is not the user
  /// and not an admin, the new and old passwords do not match or the user does
  /// not exist, a [ServiceException] is thrown. Otherwise, the user's password
  /// is updated.
  ///
  /// @param requesterId The ID of the user making the request.
  ///
  /// @param userId The ID of the user to update.
  ///
  /// @param oldPassword The user's old password.
  ///
  /// @param newPassword The user's new password.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  Future<Map<String, dynamic>> updateUserPassword(
      final int? requesterId,
      final int? userId,
      final String? oldPassword,
      final String? newPassword) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidPassword(newPassword),
        parameterName: 'newPassword');
    simpleTest(validators.isValidUserId(userId), parameterName: 'user ID');

    bool isAllowed = false;

    // Check if the requester is the user. With the exception of admins, users
    // must know their old password to change it.
    if (requesterId == userId) {
      simpleTest(validators.isValidPassword(oldPassword),
          parameterName: 'oldPassword');

      final String? salt =
          await makeDatabaseCall<String>(_userDao.getSaltById, args: [userId]);
      if (salt == null) {
        // The user does not exist.
        throw ServiceException(makeErrorResponse('User not found', status: 404),
            HttpErrorStatus.notFound);
      }

      final String hashedPassword =
          await _passwordUtils.hashPassword(oldPassword!, salt);

      // Verify that the user is credible one more time to prevent token stealing.
      final User? user =
          await makeDatabaseCall(_userDao.getUserById, args: [userId]);
      if (user == null) {
        // The user does not exist.
        throw ServiceException(makeErrorResponse('User not found', status: 404),
            HttpErrorStatus.notFound);
      }

      // The user exists, check if the password is correct.
      isAllowed = await makeDatabaseCall(_userDao.verifyLogin,
          args: [user.email, hashedPassword]);
    }

    if (!isAllowed) {
      // If the requester is not the user, check if the requester is an admin.
      // Admins can change any user's password, but they do not and they must
      // not know the user's old password.
      isAllowed =
          await makeDatabaseCall(_userDao.isAdmin, args: [requesterId!]);
    }

    if (!isAllowed) {
      // If the requester is not the user and not an admin, deny access.
      throw ServiceException(
          makeErrorResponse('Unauthorized access', status: 403),
          HttpErrorStatus.forbidden);
    }

    // Finally update the user's password. By first generating a new salt and
    // hashing the new password.
    final String salt = await _passwordUtils.generateSalt();
    final String hashedPassword =
        await _passwordUtils.hashPassword(newPassword!, salt);

    return wrapJsonCall<bool>(_userDao.updateUserPassword,
        args: [userId, hashedPassword, salt],
        test: (result) => result != null && result,
        errorStatus: 500,
        errorMessage: 'Cannot update user password',
        successMessage: 'Password updated',
        omitData: true);
  }

  /// Delete a user by ID from the database. If the user does not exist, false
  /// is returned. Otherwise, true is returned.
  Future<Map<String, dynamic>> deleteUser(
      final int? requesterId, final int? id) async {
    simpleTest(validators.isValidUserId(requesterId),
        parameterName: 'requester ID');
    simpleTest(validators.isValidUserId(id), parameterName: 'user ID');

    bool isAllowed = false;

    if (requesterId == id) {
      isAllowed = true;
    }

    if (!isAllowed) {
      isAllowed = await _userDao.isAdmin(requesterId!);
    }

    if (!isAllowed) {
      throw ServiceException(
          makeErrorResponse('Unauthorized access', status: 403),
          HttpErrorStatus.forbidden);
    }

    final bool success = await _userDao.deleteUser(id!);

    return success
        ? makeEmptySuccessResponse('User deleted')
        : makeErrorResponse('User not found');
  }

  /// Checks if a user is authenticated. If the token is invalid, e.g., expired,
  /// false is returned. Otherwise, true is returned. If the stateless flag is
  /// set to false, a database lookup is performed to check if the user is
  /// active.
  Future<bool> isAuthenticated(final String token,
      {final bool stateless = true}) {
    if (stateless) {
      return Future.value(_authManager.isValidToken(token));
    }

    // Do a stateful check that involves a database lookup.
    return _authManager.getUserId(token).then((int userId) {
      return _userDao.getUserById(userId).then((User? user) {
        return user != null && user.active;
      });
    });
  }

  List<String> getClaimErrors(final String token) {
    return _authManager.getClaimErrors(token);
  }

  /// This method resets a user's password. If the email is invalid, a
  /// [ServiceException] is thrown. Otherwise, a reset token is generated and
  /// sent to the user via email. This token is then meant to be verfied using
  /// the [changePassword] method.
  ///
  /// The success of the mailer daemon is not checked, as the email is sent
  /// asynchronously. Instead, a success message is returned regardless of the
  /// of the mailer daemon's success. Any errors are logged, however.
  ///
  /// @param email The user's email address.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  Future<Map<String, dynamic>> resetPassword(final String? email) async {
    simpleTest(validators.isValidEmail(email), parameterName: 'email');

    final User? user =
        await makeDatabaseCall<User>(_userDao.getUserByEmail, args: [email]);

    if (user != null) {
      final String token = _resetManager.generateToken(email!);

      // Send the registration token to the user asynchronously.
      _mailer.sendEmail(email, config.RESET_PASSWORD_SUBJECT,
          config.RESET_PASSWORD_BODY + token);
    }

    return makeEmptySuccessResponse('Reset token sent to email');
  }

  /// Change a user's password by reset token. If the token is invalid, a
  /// [ServiceException] is thrown. Otherwise, the user's password is changed.
  /// The token is meant to be generated using the [resetPassword] method.
  ///
  /// @param token The reset token.
  ///
  /// @param password The new password.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the token or password is invalid, the user
  /// does not exist, or any other error occurs.
  Future<Map<String, dynamic>> changePassword(
      final String? token, final String? password) async {
    simpleTest(validators.isValidPassword(password), parameterName: 'password');

    final String email = await _resetManager.getEmail(token!);

    final User? user =
        await makeDatabaseCall<User>(_userDao.getUserByEmail, args: [email]);

    if (user == null) {
      return makeErrorResponse('User not found', status: 404);
    }

    final String salt = await _passwordUtils.generateSalt();
    final String hashedPassword =
        await _passwordUtils.hashPassword(password!, salt);

    final bool success =
        await _userDao.updateUserPassword(user.id, hashedPassword, salt);

    return success
        ? makeEmptySuccessResponse('Password changed')
        : makeErrorResponse('Password not changed');
  }

  /// Authenticate a user by email and password. If the email or password is
  /// invalid, an error is returned. If the user is not active, a
  /// [ServiceException] is thrown. Otherwise, a token is generated and
  /// returned, using the key 'token' in the 'data' field of the response map.
  ///
  /// @param email The user's email address.
  ///
  /// @param password The user's password.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the email or password is invalid, the user
  /// does not exist, the user is not active, the refresh token cannot be saved
  /// to the database or any other error occurs.
  Future<Map<String, dynamic>> authenticateUser(
      final String? email, final String? password) async {
    simpleTest(validators.isValidEmail(email), parameterName: 'email');
    simpleTest(validators.isValidPassword(password), parameterName: 'password');

    final String? salt =
        await makeDatabaseCall<String?>(_userDao.getSaltByEmail, args: [email]);
    if (salt == null) {
      throw ServiceException(makeErrorResponse('User not found', status: 404),
          HttpErrorStatus.badRequest);
    }

    final String hashedPassword =
        await _passwordUtils.hashPassword(password!, salt);

    final bool success = await makeDatabaseCall<bool>(_userDao.verifyLogin,
            args: [email, hashedPassword]) ??
        false;

    if (!success) {
      throw ServiceException(
          makeErrorResponse('Invalid email or password', status: 401),
          HttpErrorStatus.unauthorized);
    }

    // The login is legitimate, but the user may not be active.
    final User? user =
        await makeDatabaseCall<User>(_userDao.getUserByEmail, args: [email]);

    if (user == null) {
      throw ServiceException(makeErrorResponse('User not found', status: 404),
          HttpErrorStatus.badRequest);
    }

    if (!user.active) {
      throw ServiceException(makeErrorResponse('User not active', status: 400),
          HttpErrorStatus.badRequest);
    }

    // The user is active, so generate a auth token and a refresh token.
    final String token = _authManager.generateAuthToken(user.id);
    final String refresh = _authManager.generateRefreshToken(user.id);

    // Insert the refresh token into the database.
    if (!await _userDao.updateRefreshToken(user.id, refresh)) {
      throw ServiceException(
          makeErrorResponse('Refresh token not saved', status: 500),
          HttpErrorStatus.internalServerError);
    }

    return makeSuccessResponse(
        {'token': token, 'refresh': refresh, 'userId': user.id},
        message: 'Authenticated');
  }

  /// Refreshes the authentication token. If the token is invalid, a
  /// [ServiceException] is thrown. Otherwise, a new token and refresh token are
  /// generated and returned.
  ///
  /// @param token The refresh token.
  ///
  /// @returns A map containing the new token and refresh token.
  ///
  /// @throws [ServiceException] If the token is invalid.
  Future<Map<String, dynamic>> refreshToken(final String? token) async {
    simpleTest(token != null && token.isNotEmpty, parameterName: 'token');

    // Check if the token is valid and retrieve the user ID.
    final int userId = await _authManager.getUserId(token!);

    // Retrieve the refresh token from the database.
    final String? refreshToken = await makeDatabaseCall<String?>(
        _userDao.getRefreshToken,
        args: [userId]);

    // Check if the refresh token is valid.
    if (refreshToken == null || refreshToken != token) {
      throw ServiceException(
          makeErrorResponse('Invalid refresh token', status: 401),
          HttpErrorStatus.unauthorized);
    }

    // Generate a new token and refresh token.
    final String newToken = _authManager.generateAuthToken(userId);
    final String newRefresh = _authManager.generateRefreshToken(userId);

    // Insert the refresh token into the database.
    if (!await makeDatabaseCall(_userDao.updateRefreshToken,
        args: [userId, newRefresh])) {
      throw ServiceException(
          makeErrorResponse('Refresh token not saved', status: 500),
          HttpErrorStatus.internalServerError);
    }

    // Return the new token and refresh token.
    return makeSuccessResponse(
        {'token': newToken, 'refresh': newRefresh, 'userId': userId},
        message: 'Authenticated');
  }

  /// Logs out a user by invalidating the refresh token. Once the token is
  /// invalidated it can no longer be used to refresh the authentication token.
  /// The authentication token will keep it's validity until it expires.
  ///
  /// @param token The refresh token.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the token is invalid or an error occurs.
  Future<Map<String, dynamic>> logout(final String? token) async {
    simpleTest(token != null && token.isNotEmpty, parameterName: 'token');

    final int userId = await _authManager.getUserId(token!);

    if (!await _userDao.invalidateRefreshToken(userId)) {
      throw ServiceException(
          makeErrorResponse('Refresh token not invalidated', status: 500),
          HttpErrorStatus.internalServerError);
    }

    return makeEmptySuccessResponse('Token revoked');
  }

  /// Registers a new user. If the name, email, or password is invalid, the
  /// user already exists, or an error occurs, a [ServiceException] is thrown.
  ///
  /// The user is created with the given name, email, and password. The user is
  /// not active until the registration token is verified. The latter of which
  /// is sent to the user's email address. To activate the user, the
  /// [activateUser] method must be called with the registration token.
  ///
  /// The lifetime of the registration token is defined in the configuration
  /// file.
  ///
  /// @param name The user's name.
  ///
  /// @param email The user's email address.
  ///
  /// @param password The user's password.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the name, email, or password is invalid, the
  /// user already exists, or any other error occurs.
  Future<Map<String, dynamic>> registerUser(
      final String? name, final String? email, final String? password) async {
    simpleTest(validators.isValidName(name), parameterName: 'name');
    simpleTest(validators.isValidEmail(email), parameterName: 'email');
    simpleTest(validators.isValidPassword(password), parameterName: 'password');

    final User? user =
        await makeDatabaseCall<User?>(_userDao.getUserByEmail, args: [email]);

    if (user != null) {
      throw ServiceException(
          makeErrorResponse('User already exists', status: 400),
          HttpErrorStatus.badRequest);
    }

    final UsersCompanion userCompanion = UsersCompanion.insert(
      name: name!,
      email: email!,
      role: Value(Role.USER),
      active: Value(false),
    );

    final String salt = await _passwordUtils.generateSalt();
    final String hashedPassword =
        await _passwordUtils.hashPassword(password!, salt);

    final response = await wrapJsonCall(_userDao.insertUser,
        args: [userCompanion, hashedPassword, salt],
        test: (result) => result != 0,
        errorStatus: 400,
        errorMessage: 'User not created: User already exists',
        successMessage: 'User created, please check email for activation.');

    if (!response['success']) {
      return response;
    }

    final int userId = response['data']['result'];
    final String registrationToken = _regManager.generateToken(userId, email);

    // Send the registration token to the user asynchronously.
    _mailer.sendEmail(email, config.REGISTRATION_SUBJECT,
        config.REGISTRATION_BODY + registrationToken);

    return response;
  }

  /// Activates a user by registration token. If the token is invalid, a
  /// [ServiceException] is thrown. Otherwise, the user is activated.
  ///
  /// @param token The registration token.
  ///
  /// @returns A map containing the status and message, indicating success or
  /// failure of the operation.
  ///
  /// @throws [ServiceException] If the registration token is invalid, the user
  /// does not exist, or any other error occurs.
  Future<Map<String, dynamic>> activateUser(final String? token) async {
    if (token == null) {
      return makeErrorResponse('Missing registration token', status: 400);
    }

    late final int userId;
    userId = await _regManager.getUserId(token);

    final User? user =
        await makeDatabaseCall<User?>(_userDao.getUserById, args: [userId]);
    if (user == null) {
      return makeErrorResponse('User not found', status: 400);
    }

    final UsersCompanion companion =
        user.copyWith(active: true).toCompanion(false);

    final bool? success =
        await makeDatabaseCall<bool>(_userDao.updateUser, args: [companion]);
    if (success == null || !success) {
      return makeErrorResponse('User not activated');
    }

    return makeEmptySuccessResponse('User activated');
  }

  /// Retrieve the requester's ID from the token. If the token is invalid, a
  /// [JWTError] is thrown. Otherwise, the requester's ID is returned.
  ///
  /// @param token The JWT token.
  ///
  /// @returns The requester's ID.
  ///
  /// @throws [JWTError] If the token is invalid.
  Future<int> getRequesterId(final String token) {
    return _authManager.getUserId(token);
  }

  /// Check if the requester is an admin. If the token is invalid, a [JWTError]
  /// is thrown. Otherwise, true is returned if the requester is an admin,
  /// otherwise false is returned.
  ///
  /// @param token The JWT token.
  ///
  /// @returns True if the requester is an admin, otherwise false.
  ///
  /// @throws [JWTError] If the token is invalid.
  Future<bool> isAdmin(String token) {
    return _authManager.getUserId(token).then((int userId) {
      return _userDao.isAdmin(userId);
    });
  }

  /// Delete all inactive users from the database. If no users are deleted,
  /// false is returned. Otherwise, true is returned.
  ///
  /// *This method is not meant to be called from the API layer, but is instead
  /// meant to be used to clean up the database.*
  ///
  /// @returns True if users were deleted, otherwise false.
  Future<bool> deleteInactiveUsers() {
    return _userDao.deleteInactiveUsers();
  }
}
