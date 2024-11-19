import '../models/responses/login_response.dart';
import '../models/requests/login_request.dart';
import '../persistence/http_utils.dart';
import '../persistence/api_constants.dart';

class AuthenticationApi {
  final String baseUri;
  AuthenticationApi(this.baseUri);

  Future<LoginResponse> login({
    required final String email,
    required final String password,
  }) async {
    final body = LoginRequest(email: email, password: password).toJson();

    final response = await HttpUtils.performPost(
      path: Uri.parse(ApiConstants.getLoginUrl()),
      body: body,
    );

    return LoginResponse.fromJson(response['data']);
  }

  Future<LoginResponse> refresh({
    required final String refreshToken,
  }) async {
    final body = {
      'refresh': refreshToken,
    };

    final response = await HttpUtils.performPost(
      path: Uri.parse(ApiConstants.getRefreshTokenUrl()),
      body: body,
    );

    return LoginResponse.fromJson(response['data']);
  }
}
