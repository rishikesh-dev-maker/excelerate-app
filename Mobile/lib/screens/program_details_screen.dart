import 'package:flutter/material.dart';
import '../models/program.dart';
import '../repositories/program_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailsScreen({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  bool _isEnrolling = false;
  bool _isUpdatingModule = false;
  late Program _program;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _program = widget.program;
    _loadProgramDetails();
  }

  Future<void> _loadProgramDetails() async {
    try {
      final program = await _programRepository.getProgramById(widget.program.id);
      if (!mounted) return;
      setState(() => _program = program);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  void _handleContinueProgram() {
    setState(() => _isEnrolling = true);

    // Simulate enrollment
    Future.delayed(const Duration(seconds: 1), () {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to ${_program.title}! Starting next module...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _isEnrolling = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXCELERATE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadError != null) ...[
                InlineErrorBanner(
                  message: 'Showing saved details. Could not refresh: $_loadError',
                ),
                const SizedBox(height: 16),
              ],
              // Header
              Text(
                'Program Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Program Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _program.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_program.duration} • ${_program.category}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hands-on project • GitHub collaboration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // What You'll Learn Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you\'ll learn',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ..._program.learningOutcomes
                      .map((outcome) => _buildOutcomeItem(context, outcome))
                      .toList(),
                ],
              ),
              const SizedBox(height: 32),

              // Program Journey Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program journey',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ..._program.journey
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildJourneyItem(
                          context,
                          entry.value,
                          moduleIndex: entry.key,
                          isCompleted: _program.completedModules.contains(entry.key),
                        ),
                      )
                      .toList(),
                ],
              ),
              const SizedBox(height: 28),

              // Continue Button
              Center(
                child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: _isEnrolling ? null : _handleContinueProgram,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: _isEnrolling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _program.status == 'In progress'
                              ? 'Continue Program'
                              : 'Join Program',
                        ),
                ),
                ),
              ),
              const SizedBox(height: 16),

              // Enrollment Form Button
              Center(
                child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPurple,
                    side: const BorderSide(color: AppTheme.primaryPurple),
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/enrollment',
                    arguments: _program,
                  ),
                  child: const Text('Enroll Now'),
                ),
                ),
              ),
              const SizedBox(height: 16),

              // Feedback Button
              Center(
                child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryOrange,
                    side: const BorderSide(color: AppTheme.primaryOrange),
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/feedback',
                    arguments: _program,
                  ),
                  child: const Text('Share Feedback'),
                ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeItem(BuildContext context, String outcome) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.primaryPurple,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              outcome,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyItem(
    BuildContext context,
    String journey, {
    required int moduleIndex,
    bool isCompleted = false,
  }) {
    return GestureDetector(
      onTap: () => _showModuleDetails(context, moduleIndex, journey, isCompleted),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? AppTheme.successGreen : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            if (isCompleted)
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.accentGray,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderColor),
                ),
              ),
            Expanded(
              child: Text(
                journey,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isCompleted ? AppTheme.successGreen : AppTheme.textDark,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModuleDetails(
    BuildContext context,
    int moduleIndex,
    String module,
    bool isCompleted,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Module ${moduleIndex + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module),
            const SizedBox(height: 12),
            Text(
              isCompleted ? 'Status: Completed' : 'Status: Not completed yet',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.textLight,
                  ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _isUpdatingModule
                ? null
                : () async {
                    Navigator.pop(dialogContext);
                    await _updateModuleCompletion(moduleIndex, !isCompleted);
                  },
            child: Text(isCompleted ? 'Mark incomplete' : 'Mark complete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateModuleCompletion(int moduleIndex, bool isComplete) async {
    setState(() => _isUpdatingModule = true);
    try {
      final updatedProgram = await _programRepository.updateModuleCompletion(
        program: _program,
        moduleIndex: moduleIndex,
        isComplete: isComplete,
      );
      if (!mounted) return;
      setState(() => _program = updatedProgram);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isComplete ? 'Module marked complete.' : 'Module marked incomplete.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update module: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingModule = false);
    }
  }
}
