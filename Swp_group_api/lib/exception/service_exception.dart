enum HttpErrorStatus {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  internalServerError,
  unknown,
}

HttpErrorStatus getStatusFromCode(final int status) {
  switch (status) {
    case 400:
      return HttpErrorStatus.badRequest;
    case 401:
      return HttpErrorStatus.unauthorized;
    case 403:
      return HttpErrorStatus.forbidden;
    case 404:
      return HttpErrorStatus.notFound;
    case 409:
      return HttpErrorStatus.conflict;
    case 500:
      return HttpErrorStatus.internalServerError;
    default:
      return HttpErrorStatus.unknown;
  }
}

final class ServiceException implements Exception {
  late final Map<String, dynamic> _data;
  late final HttpErrorStatus _errorCode;

  ServiceException(
      final Map<String, dynamic> data, final HttpErrorStatus errorCode)
      : _data = data,
        _errorCode = errorCode;

  Map<String, dynamic> get data => _data;

  HttpErrorStatus get errorCode => _errorCode;
}
