class ApiBaseException implements Exception {
  String message;
  int returnCode;

  ApiBaseException(this.message, this.returnCode);
}

class ApiClientException extends ApiBaseException {
  ApiClientException(super.errorMessage, super.returnCode);
}

class ApiServerException extends ApiBaseException {
  ApiServerException(super.errorMessage, super.returnCode);
}
