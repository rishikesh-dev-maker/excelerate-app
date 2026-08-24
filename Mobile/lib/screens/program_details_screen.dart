import 'package:flutter/material.dart';
import '../models/program.dart';
import '../theme/app_theme.dart';

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
  bool _isEnrolling = false;

  void _handleContinueProgram() {
    setState(() => _isEnrolling = true);

    // Simulate enrollment
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to ${widget.program.title}! Starting next module...',
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
                      widget.program.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.program.duration} • ${widget.program.category}',
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
                  ...widget.program.learningOutcomes
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
                  ...widget.program.journey
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildJourneyItem(
                          context,
                          entry.value,
                          isCompleted: widget.program.status == 'In progress' &&
                              entry.key < 2, // Show first 2 as completed for demo
                        ),
                      )
                      .toList(),
                ],
              ),
              const SizedBox(height: 28),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEnrolling ? null : _handleContinueProgram,
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
                          widget.program.status == 'In progress'
                              ? 'Continue Program'
                              : 'Join Program',
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Enrollment Form Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPurple,
                    side: const BorderSide(color: AppTheme.primaryPurple),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/enrollment',
                    arguments: widget.program,
                  ),
                  child: const Text('Enroll Now'),
                ),
              ),
              const SizedBox(height: 16),

              // Feedback Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryOrange,
                    side: const BorderSide(color: AppTheme.primaryOrange),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/feedback',
                    arguments: widget.program,
                  ),
                  child: const Text('Share Feedback'),
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
    bool isCompleted = false,
  }) {
    return Container(
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
                    color: isCompleted ? AppTheme.successGreen : AppTheme.textDark,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
