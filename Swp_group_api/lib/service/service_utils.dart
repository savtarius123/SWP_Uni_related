import 'package:backend/exception/service_exception.dart';
import 'package:drift/drift.dart';

/// Wraps a call to the database in a try-catch block and catches any exceptions
/// that are thrown. If the call is successful, it will return the result of the
/// call. If the call fails, it will rethrow a special [ServiceException] with
/// appropriate status code and message as a Map that can be converted to JSON.
///
/// @param f The function to call.
///
/// @param args The arguments to pass to the function.
///
/// @param debug Whether to include debug information in the response.
///
/// @return The result of the call.
///
/// @throws ServiceException If the call fails.
///
/// @example
/// ```dart
/// final Group? group = await makeDatabaseCall<Group>(() =>
///   databaseService.getGroupById(1));
/// ```
Future<T?> makeDatabaseCall<T>(final Function f,
    {final List args = const [], final bool debug = false}) async {
  try {
    // Fetch result and enforce type safety.
    final T? result = await Function.apply(f, args);

    // Convert result to JSON if not null.
    return result;
  } on CouldNotRollBackException catch (e) {
    final String message = debug ? ': ${e.cause}' : '.';

    throw ServiceException(
        makeErrorResponse('Operation failed due to Database error$message',
            status: 500),
        HttpErrorStatus.internalServerError);
  } on DriftWrappedException catch (e) {
    final String message = debug ? ': ${e.cause}' : '.';

    throw ServiceException(
        makeErrorResponse('Operation failed due to Database error$message',
            status: 500),
        HttpErrorStatus.internalServerError);
  } on InvalidDataException catch (e) {
    final String message = debug ? ': ${e.toString()}' : '.';

    throw ServiceException(
        makeErrorResponse('Operation failed due to invalid data$message',
            status: 400),
        HttpErrorStatus.badRequest);
  } on Exception catch (e) {
    final String message = debug ? ': ${e.toString()}' : '.';

    throw ServiceException(
        makeErrorResponse('Operation failed$message', status: 500),
        HttpErrorStatus.internalServerError);
  }
}

/// Wraps a call to the database in a try-catch block and catches any exceptions
/// that are thrown. If the call is successful, it will return a JSON response
/// with the data from the call. If the call fails, it will rethrow a
/// special [ServiceException] with the appropriate status code and message as a
/// Map that can be converted to JSON.
///
/// @param f The function to call.
///
/// @param args The arguments to pass to the function.
///
/// @param successMessage The success message to return on success.
///
/// @param errorMessage The error message to return on error.
///
/// @param errorStatus The status code to return on error.
///
/// @param test The test function to run on the result.
///
/// @param omitData Whether to omit the data from the response.
///
/// @param allowList List of allowed keys in the response.
///
/// @param debug Whether to include debug information in the response.
///
/// @return A JSON response with the data from the call.
///
/// @throws ServiceException If the call fails.
///
/// @example
/// ```dart
/// final Map<String, dynamic> response = await wrapJsonCall(
///  () => databaseService.getGroupById(1),
///  successMessage: 'Operation succeeded',
///  errorMessage: 'Operation failed',
///  errorStatus: 500,
///  test: (final Group? group) => group != null,
///  allowList: ['id', 'name', 'description'],
///  debug: false,
/// );
/// ```
Future<Map<String, dynamic>> wrapJsonCall<T>(final Function f,
    {final List args = const [], // The arguments to pass to the function.
    final String successMessage = 'Operation succeeded', // The success message.
    final String errorMessage = 'Operation failed', // The error message.
    final int errorStatus = 500, // The status code to return on error.
    final bool Function(T?)? test, // The test function to run on the result.
    final bool omitData = false, // Whether to omit the data from the response.
    final List allowList = const [], // List of allowed keys in the response.
    final bool debug = false}) async {
  // Fetch result and enforce type safety.
  final T? result = await makeDatabaseCall<T>(f, args: args, debug: debug);

  if (test != null) {
    if (!test(result)) {
      throw ServiceException(
          makeErrorResponse(errorMessage, status: errorStatus),
          getStatusFromCode(errorStatus));
    }
  }

  late final Map<String, dynamic> data;

  if (result is DataClass) {
    final Map<String, dynamic> json = result.toJson();

    // Remove any keys specified in the omit list.
    if (allowList.isNotEmpty) {
      for (final key in json.keys.toList()) {
        if (!allowList.contains(key)) {
          json.remove(key);
        }
      }
    }

    data = json;
  } else if (result is List<DataClass>) {
    final List<Map<String, dynamic>> json =
        result.map((e) => e.toJson()).toList();

    // Remove any keys specified in the omit list.
    if (allowList.isNotEmpty) {
      for (final item in json) {
        for (final key in item.keys.toList()) {
          if (!allowList.contains(key)) {
            item.remove(key);
          }
        }
      }
    }

    data = {'result': json};
  } else if (result is bool || result is int || result is String) {
    data = {'result': result};
  } else {
    data = {};
  }

  return makeSuccessResponse(omitData ? {} : data, message: successMessage);
}

void simpleTest(final bool triggerException, {final String? parameterName}) {
  if (!triggerException) {
    throw ServiceException(
        makeErrorResponse('Invalid ${parameterName ?? 'parameter'}',
            status: 400),
        HttpErrorStatus.badRequest);
  }
}

/// Simple wrapper to create a successful response with a message. The data
/// must be a JSON serializable Map.
///
/// @param data The data to include in the response.
///
/// @param message The message to include in the response.
///
/// @return A successful response with the data and message.
Map<String, dynamic> makeSuccessResponse(final Map<String, dynamic> data,
    {final String message = ''}) {
  return {
    'data': data,
    'status': 200,
    'success': true,
    'message': message,
  };
}

/// Simple wrapper to create a successful response with a message. This is
/// merely for better readability and should be used when the response does not
/// contain any data.
///
/// @param message The message to include in the response.
///
/// @return A successful response with the message.
///
/// @see makeSuccessResponse
Map<String, dynamic> makeEmptySuccessResponse(final String message) {
  return {
    'data': {},
    'success': true,
    'message': message,
  };
}

/// Simple wrapper to create an error response with a message. The status code
/// is set to 500 by default.
///
/// @param message The message to include in the response.
///
/// @param status The status code to include in the response.
///
/// @return An error response with the message and status code.
Map<String, dynamic> makeErrorResponse(final String message,
    {final int status = 500}) {
  return {
    'data': {},
    'status': status,
    'success': false,
    'message': message,
  };
}
