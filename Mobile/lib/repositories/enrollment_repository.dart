import '../core/api/api_client.dart';
import '../models/enrollment.dart';

class EnrollmentRepository {
  final ApiClient _apiClient;

  EnrollmentRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<Enrollment> enroll({
    required int userId,
    required int programId,
    required String name,
    required String email,
    required String interest,
  }) async {
    final body = {
      'userId': userId,
      'programId': programId,
      'name': name,
      'email': email,
      'interest': interest,
      'status': 'ENROLLED',
    };
    final response = await _apiClient.post('/enrollments', body: body);
    return Enrollment.fromJson(response);
  }

  Future<List<Enrollment>> getEnrollmentsForUser(int userId) async {
    final data = await _apiClient.get(
      '/enrollments',
      queryParams: {'userId': userId.toString()},
    );
    return (data as List).map((json) => Enrollment.fromJson(json)).toList();
  }
}
