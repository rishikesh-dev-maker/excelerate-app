class Program {
  final int id;
  final String title;
  final String category;
  final String description;
  final String duration;
  final List<String> learningOutcomes;
  final String journey;
  final String status;
  final int progressPercent;

  Program({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.duration,
    required this.learningOutcomes,
    required this.journey,
    required this.status,
    required this.progressPercent,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      learningOutcomes: json['learningOutcomes'] != null
          ? List<String>.from(json['learningOutcomes'])
          : [],
      journey: json['journey'] ?? '',
      status: json['status'] ?? 'Available',
      progressPercent: json['progressPercent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'duration': duration,
    'learningOutcomes': learningOutcomes,
    'journey': journey,
    'status': status,
    'progressPercent': progressPercent,
  };
}
