import 'package:flutter/material.dart';

import '../models/program.dart';
import '../repositories/program_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  List<Program> _programs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final programs = await _programRepository.getPrograms();
      if (!mounted) return;
      setState(() {
        _programs = programs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onNavBarTapped(int index) {
    if (index == 2) return;

    final routes = ['/home', '/programs', '/progress', '/profile'];
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final activePrograms =
        _programs.where((program) => program.status == 'In progress').toList();
    final overallProgress = _programs.isEmpty
        ? 0
        : (_programs.fold<int>(
                    0, (total, program) => total + program.progressPercent) /
                _programs.length)
            .round();

    return Scaffold(
      appBar: AppBar(title: AppTheme.wordmark()),
      body: _isLoading
          ? const LoadingView(message: 'Loading your progress...')
          : _errorMessage != null
              ? ErrorView(message: _errorMessage!, onRetry: _loadProgress)
              : RefreshIndicator(
                  onRefresh: _loadProgress,
                  color: AppTheme.primaryPink,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Your progress',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track the programs you are currently working through.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      _buildSummary(context, activePrograms.length, overallProgress),
                      const SizedBox(height: 28),
                      Text(
                        'Program progress',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      if (_programs.isEmpty)
                        Text(
                          'No programs are available yet.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        ..._programs.map(
                          (program) => _buildProgramProgress(context, program),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: _onNavBarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, int activeCount, int progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(context, '$activeCount', 'active programs'),
          Container(width: 1, height: 52, color: AppTheme.borderColor),
          _buildMetric(context, '$progress%', 'overall progress'),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryPink,
              ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildProgramProgress(BuildContext context, Program program) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/program-details', arguments: program)
          .then((_) => _loadProgress()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textLight),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: program.progressPercent / 100,
                minHeight: 8,
                backgroundColor: AppTheme.accentGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryPink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${program.progressPercent}% complete · Tap to view modules',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
