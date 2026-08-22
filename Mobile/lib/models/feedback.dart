class FeedbackModel {
  final int? id;
  final int userId;
  final int programId;
  final String category;
  final int rating;
  final String message;

  FeedbackModel({
    this.id,
    required this.userId,
    required this.programId,
    required this.category,
    required this.rating,
    required this.message,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] != null
          ? (json['id'] is int ? json['id'] : int.parse(json['id'].toString()))
          : null,
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      programId: json['programId'] is int
          ? json['programId']
          : int.parse(json['programId'].toString()),
      category: json['category'] ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.parse(json['rating'].toString()),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'userId': userId,
    'programId': programId,
    'category': category,
    'rating': rating,
    'message': message,
  };
}
