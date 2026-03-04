import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Token> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: FormData.fromMap({'username': email, 'password': password}),
      contentType: 'application/x-www-form-urlencoded',
    );
    final token = Token.fromJson(response.data);
    await _apiClient.saveToken(token.accessToken);
    return token;
  }

  Future<User> register(String email, String password, String nickname) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'nickname': nickname},
    );
    return User.fromJson(response.data);
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null;
  }
}
