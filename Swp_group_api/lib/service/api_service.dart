import 'package:backend/config/config.dart';
import 'package:backend/exception/service_exception.dart';
import 'package:backend/middleware/api_token_manager.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/service/service_utils.dart';
import 'package:backend/util/mailer.dart';
import 'package:backend/util/validators.dart';

class ApiService {
  late final AppDatabase db;
  late final Config config;
  late final Validators validators;
  late final ApiTokenManger _apiTokenManger;
  late final UserDao _userDao;
  late final Mailer _mailer;

  ApiService(this.db, this.config)
      : validators = Validators(config),
        _userDao = db.userDao,
        _apiTokenManger = ApiTokenManger(config),
        _mailer = Mailer(config);

  /// Generates a token for the user with the given [email] and sends it to the
  /// user's email address. The token will be valid for the duration specified
  /// by the [daysValid] parameter. If no value is provided, the token will be
  /// valid for 30 days.
  ///
  /// @param email The email address of the user.
  ///
  /// @param requesterId The ID of the user requesting the token.
  ///
  /// @param daysValid The number of days the token will be valid.
  ///
  /// @return A map with a success message.
  ///
  /// @throws [ServiceException] If the email address is invalid, the requester
  /// ID is invalid, the number of days is invalid or the user does not exist in
  /// the database.
  Future<Map<String, dynamic>> generateApiToken(
      final String? email,
      {final int? daysValid = 30}) async {
    simpleTest(validators.isValidEmail(email), parameterName: 'email');
    simpleTest(validators.isValidDays(daysValid), parameterName: 'days');

    final String token =
        _apiTokenManger.generateToken(email!, daysValid: daysValid!);

    // Send the token to the user's email address asynchonously.
    _mailer.sendEmail(
        email, config.API_TOKEN_SUBJECT, config.API_TOKEN_BODY + token);

    return makeEmptySuccessResponse('Token sent to email');
  }

  /// Checks whether the token is valid and returns true if it is. If the
  /// [stateless] parameter is set to true, the method will only check the
  /// token's validity. If set to false, the method will also check if the
  /// token's email is associated with a user in the database and the user is
  /// active.
  ///
  /// @param token The token to check.
  ///
  /// @param stateless Whether to check the token's email in the database.
  ///
  /// @return True if the token is valid.
  ///
  /// @throws [ServiceException] If the token is invalid or the user is unknown.
  Future<bool> isAuthorized(final String? token,
      {final bool stateless = true}) async {
    if (token == null) {
      throw ServiceException(
          makeErrorResponse('No api token provided', status: 400),
          HttpErrorStatus.badRequest);
    }

    if (stateless) {
      return _apiTokenManger.isValidToken(token);
    } else {
      final String email = await _apiTokenManger.getEmail(token);
      simpleTest(validators.isValidEmail(email), parameterName: 'email');

      final User? user =
          await makeDatabaseCall(_userDao.getUserByEmail, args: [email]);
      if (user == null || !user.active) {
        throw ServiceException(
            makeErrorResponse('Invalid api token: User unknown', status: 400),
            HttpErrorStatus.badRequest);
      }

      return true;
    }
  }
}
