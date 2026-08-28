import '../core/api/api_client.dart';
import '../models/program.dart';

class ProgramRepository {
  final ApiClient _apiClient;

  ProgramRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Program>> getPrograms() async {
    final data = await _apiClient.get('/programs');
    return (data as List).map((json) => Program.fromJson(json)).toList();
  }

  Future<Program> getProgramById(int id) async {
    final data = await _apiClient.get('/programs/$id');
    return Program.fromJson(data);
  }

  Future<Program> updateModuleCompletion({
    required Program program,
    required int moduleIndex,
    required bool isComplete,
  }) async {
    final completedModules = [...program.completedModules];
    if (isComplete) {
      if (!completedModules.contains(moduleIndex)) completedModules.add(moduleIndex);
    } else {
      completedModules.remove(moduleIndex);
    }
    completedModules.sort();

    final moduleCount = program.journey.length;
    final progressPercent = moduleCount == 0
        ? 0
        : ((completedModules.length / moduleCount) * 100).round();
    final status = completedModules.isEmpty
        ? 'Available'
        : (completedModules.length == moduleCount ? 'Completed' : 'In progress');
    final data = await _apiClient.patch(
      '/programs/${program.id}',
      body: {
        'completedModules': completedModules,
        'progressPercent': progressPercent,
        'status': status,
      },
    );
    return Program.fromJson(data);
  }

  Future<List<Program>> searchPrograms(String query) async {
    final data = await _apiClient.get('/programs', queryParams: {'q': query});
    return (data as List).map((json) => Program.fromJson(json)).toList();
  }

  Future<List<Program>> getProgramsByCategory(String category) async {
    final data = await _apiClient.get(
      '/programs',
      queryParams: {'category': category},
    );
    return (data as List).map((json) => Program.fromJson(json)).toList();
  }
}
