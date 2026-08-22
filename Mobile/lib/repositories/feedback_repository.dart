import '../core/api/api_client.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  final ApiClient _apiClient;

  FeedbackRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<FeedbackModel> submitFeedback({
    required int userId,
    required int programId,
    required String category,
    required int rating,
    required String message,
  }) async {
    final body = {
      'userId': userId,
      'programId': programId,
      'category': category,
      'rating': rating,
      'message': message,
    };
    final response = await _apiClient.post('/feedback', body: body);
    return FeedbackModel.fromJson(response);
  }

  Future<List<FeedbackModel>> getFeedbackForUser(int userId) async {
    final data = await _apiClient.get(
      '/feedback',
      queryParams: {'userId': userId.toString()},
    );
    return (data as List).map((json) => FeedbackModel.fromJson(json)).toList();
  }
}
