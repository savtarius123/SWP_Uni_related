import 'auth_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../persistence/authentication_api.dart';
import '../persistence/api_constants.dart';
import '../models/responses/login_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../exceptions/api_exceptions.dart';

part 'auth_state_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  final _storage = const FlutterSecureStorage();
  final _apiClient = AuthenticationApi(ApiConstants.baseUrl);

  @override
  Future<AuthStatus> build() async {
    return AuthStatus.unauthenticated;
  }

  Future<void> storeLoginResponse(
      {required final LoginResponse loginResponse}) async {
    await _storage.write(key: 'token', value: loginResponse.token);
    await _storage.write(key: 'refresh', value: loginResponse.refresh);
    await _storage.write(key: 'userId', value: loginResponse.userId.toString());
  }

  Future<void> deleteLoginResponse() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh');
    await _storage.delete(key: 'userId');
  }

  Future<LoginResponse> getAuthInfo() async {
    final String? token = await _storage.read(key: 'token');
    final String? refresh = await _storage.read(key: 'refresh');
    final String? userIdString = await _storage.read(key: 'userId');

    // If no auth info is stored, the user is unauthenticated.
    if (token == null || refresh == null || userIdString == null) {
      state = const AsyncData(AuthStatus.unauthenticated);

      return Future.error('User not authenticated');
    }
    // If the auth token is expired, try to refresh it.
    if (JwtDecoder.isExpired(token)) {
      // But if the refresh token is also expired, the user is unauthenticated.
      if (JwtDecoder.isExpired(refresh)) {
        deleteLoginResponse();
        state = const AsyncData(AuthStatus.unauthenticated);
        return Future.error('User not authenticated');
      }
      // Otherwise try to finally refresh the auth token.
      try {
        final loginResponse = await _apiClient.refresh(refreshToken: refresh);
        await storeLoginResponse(loginResponse: loginResponse);

        return loginResponse;
      } catch (e) {
        // If the refresh fails, the user is unauthenticated.
        state = const AsyncData(AuthStatus.unauthenticated);

        return Future.error('User not authenticated');
      }
    }
    final int? userId = int.tryParse(userIdString);
    if (userId == null) {
      state = const AsyncData(AuthStatus.unauthenticated);

      return Future.error('User not authenticated');
    }

    return LoginResponse(token: token, refresh: refresh, userId: userId);
  }

  Future<AuthStatus> login({
    required final String email,
    required final String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final loginResponse = await _apiClient.login(
        email: email,
        password: password,
      );

      await storeLoginResponse(loginResponse: loginResponse);
      state = const AsyncData(AuthStatus.authenticated);

      return AuthStatus.authenticated;
    } on ApiBaseException catch (e) {
      state = const AsyncData(AuthStatus.unauthenticated);

      return Future.error('Login failed: ${e.message}');
    } catch (e) {
      state = const AsyncData(AuthStatus.unauthenticated);

      return Future.error('Login failed: Unknown error: $e');
    }
  }
}
