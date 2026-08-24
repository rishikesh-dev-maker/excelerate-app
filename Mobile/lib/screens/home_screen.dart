import 'package:flutter/material.dart';
import '../models/program.dart';
import '../theme/app_theme.dart';
import '../repositories/program_repository.dart';
import '../widgets/state_views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  int _selectedIndex = 0;

  List<Program> _programs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
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
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        // Stay on home
        break;
      case 1:
        Navigator.of(context).pushNamed('/programs');
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress tracking coming in Week 3')),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile management coming in future')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProgramCount =
        _programs.where((p) => p.status == 'In progress').length;
    final overallProgress = _programs.isEmpty
        ? 0
        : (_programs.fold<int>(0, (sum, p) => sum + p.progressPercent) /
                _programs.length)
            .toInt();

    return Scaffold(
      appBar: AppBar(
        title: AppTheme.wordmark(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Hi, Learner 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingView(message: 'Loading your dashboard...')
          : _errorMessage != null
              ? ErrorView(message: _errorMessage!, onRetry: _loadPrograms)
              : RefreshIndicator(
                  color: AppTheme.primaryPink,
                  onRefresh: _loadPrograms,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Header
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, Learner 🌟',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Continue building your skills.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Learning Snapshot Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGray,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Your learning snapshot',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.textLight),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          activeProgramCount.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: AppTheme.primaryPurple,
                                                fontSize: 28,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'active programs',
                                          style:
                                              Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 60,
                                      color: AppTheme.borderColor,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '$overallProgress%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: AppTheme.primaryPurple,
                                                fontSize: 28,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'overall progress',
                                          style:
                                              Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Continue Learning Section
                          Text(
                            'Continue learning',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          if (_programs.where((p) => p.status == 'In progress').isEmpty)
                            Text(
                              'No active programs yet — explore the catalogue to get started.',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            ..._programs
                                .where((p) => p.status == 'In progress')
                                .map((program) => _buildProgramCard(context, program))
                                .toList(),
                          const SizedBox(height: 32),

                          // Recommended Programs Section
                          Text(
                            'Recommended programs',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ..._programs
                              .where((p) => p.status == 'Available')
                              .take(2)
                              .map((program) =>
                                  _buildRecommendationTile(context, program))
                              .toList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Program program) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/program-details',
        arguments: program,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              program.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: program.progressPercent / 100,
                minHeight: 8,
                backgroundColor: AppTheme.accentGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.statusInProgress,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${program.progressPercent}% complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(BuildContext context, Program program) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/program-details',
        arguments: program,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
