import 'package:flutter/material.dart';
import '../models/program.dart';
import '../theme/app_theme.dart';
import '../repositories/program_repository.dart';
import '../widgets/state_views.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({Key? key}) : super(key: key);

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Program> _allPrograms = [];
  List<Program> _filteredPrograms = [];
  int _selectedNavIndex = 1;

  bool _isLoading = true;
  String? _errorMessage;

  final List<String> categories = [
    'All',
    'Technology',
    'Business',
    'Design',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPrograms);
    _loadPrograms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _allPrograms = programs;
        _filteredPrograms = programs;
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

  void _filterPrograms() {
    setState(() {
      _filteredPrograms = _allPrograms.where((program) {
        final matchesSearch = program.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            program.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesCategory =
            _selectedCategory == 'All' || program.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _filterPrograms();
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Stay on programs
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
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.wordmark(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programs',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore experiential learning opportunities.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              enabled: !_isLoading && _errorMessage == null,
              decoration: InputDecoration(
                hintText: 'Search programs',
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_isLoading || _errorMessage != null)
                            ? null
                            : (_) => _onCategorySelected(category),
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryPurple,
                        labelStyle: TextStyle(
                          color: _selectedCategory == category
                              ? Colors.white
                              : AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: _selectedCategory == category
                              ? AppTheme.primaryPurple
                              : AppTheme.borderColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Programs List / Loading / Error
          Expanded(
            child: _isLoading
                ? const LoadingView(message: 'Loading programs...')
                : _errorMessage != null
                    ? ErrorView(
                        message: _errorMessage!,
                        onRetry: _loadPrograms,
                      )
                    : _filteredPrograms.isEmpty
                        ? Center(
                            child: Text(
                              'No programs found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : RefreshIndicator(
                            color: AppTheme.primaryPink,
                            onRefresh: _loadPrograms,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredPrograms.length,
                              itemBuilder: (context, index) {
                                final program = _filteredPrograms[index];
                                return _buildProgramTile(context, program);
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
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

  Widget _buildProgramTile(BuildContext context, Program program) {
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
            Row(
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
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGray,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                program.status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: program.status == 'In progress'
                          ? AppTheme.statusInProgress
                          : AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
