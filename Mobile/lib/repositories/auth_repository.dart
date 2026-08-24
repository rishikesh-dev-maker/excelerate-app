import '../core/api/api_client.dart';
import '../core/api/api_exceptions.dart';
import '../models/user.dart';
import '../services/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  Future<User> login(String email, String password) async {
    // Query users matching email via json-server
    final List<dynamic> users = await _apiClient.get(
      '/users',
      queryParams: {'email': email},
    );

    if (users.isEmpty) {
      throw UnauthorizedException('Invalid email or password');
    }

    final userMap = users.first as Map<String, dynamic>;
    if (userMap['password'] != password) {
      throw UnauthorizedException('Invalid email or password');
    }

    final user = User.fromJson(userMap);
    await _tokenStorage.saveToken('mock-jwt-token-${user.id}', user.id);
    return user;
  }

  Future<User> register(String email, String password, String name) async {
    // Check if user exists
    final List<dynamic> existing = await _apiClient.get(
      '/users',
      queryParams: {'email': email},
    );
    if (existing.isNotEmpty) {
      throw ValidationException('User with this email already exists');
    }

    final body = {
      'email': email,
      'password': password,
      'name': name,
      'role': 'LEARNER',
    };

    final response = await _apiClient.post('/users', body: body);
    final user = User.fromJson(response);
    await _tokenStorage.saveToken('mock-jwt-token-${user.id}', user.id);
    return user;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  Future<int?> getCurrentUserId() async {
    return await _tokenStorage.getUserId();
  }
}
