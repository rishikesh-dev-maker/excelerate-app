class Program {
  final int id;
  final String title;
  final String category;
  final String description;
  final String duration;
  final List<String> learningOutcomes;
  final List<String> journey;
  final List<int> completedModules;
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
    required this.completedModules,
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
      journey: json['journey'] is List
          ? List<String>.from(json['journey'])
          : (json['journey']?.toString().split(' -> ') ?? []),
      completedModules: json['completedModules'] is List
          ? List<int>.from(json['completedModules'])
          : _completedModulesFromProgress(
              json['journey'] is List
                  ? (json['journey'] as List).length
                  : (json['journey']?.toString().split(' -> ').length ?? 0),
              json['progressPercent'] ?? 0,
            ),
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
    'completedModules': completedModules,
    'status': status,
    'progressPercent': progressPercent,
  };

  static List<int> _completedModulesFromProgress(
    int moduleCount,
    int progressPercent,
  ) {
    if (moduleCount == 0) return [];
    final completedCount = ((progressPercent / 100) * moduleCount)
        .floor()
        .clamp(0, moduleCount);
    return List<int>.generate(completedCount, (index) => index);
  }
}
