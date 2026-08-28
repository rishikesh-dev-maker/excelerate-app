import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/program.dart';
import '../repositories/auth_repository.dart';
import '../repositories/feedback_repository.dart';
import '../widgets/state_views.dart';

class FeedbackScreen extends StatefulWidget {
  final Program program;

  const FeedbackScreen({Key? key, required this.program}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final FeedbackRepository _feedbackRepository = FeedbackRepository();
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  int _rating = 0;
  String? _feedbackCategory;
  String? _errorMessage;

  final List<String> _feedbackCategories = [
    'Bug report',
    'Suggestion',
    'Praise',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String? _validateFeedback(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please share your feedback';
    }
    if (value.trim().length < 10) {
      return 'Please provide at least 10 characters';
    }
    return null;
  }

  String? _validateRating(int? value) {
    if (value == null || value == 0) {
      return 'Please select a rating';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a feedback category';
    }
    return null;
  }

  void _handleSubmitFeedback() async {
    setState(() {
      _errorMessage = null;
      _hasAttemptedSubmit = true;
    });

    final ratingError = _validateRating(_rating);
    final categoryError = _validateCategory(_feedbackCategory);
    final formValid = _formKey.currentState!.validate();

    if (categoryError != null) {
      setState(() => _errorMessage = categoryError);
      return;
    }

    if (ratingError != null) {
      setState(() => _errorMessage = ratingError);
      return;
    }

    if (!formValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        throw StateError('Please sign in before submitting feedback.');
      }
      await _feedbackRepository.submitFeedback(
        userId: userId,
        programId: widget.program.id,
        category: _feedbackCategory!,
        rating: _rating,
        message: _feedbackController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You! 🙏'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your feedback has been submitted',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Category: $_feedbackCategory',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < _rating ? AppTheme.primaryOrange : Colors.grey,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We appreciate your input!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTheme.wordmark(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasAttemptedSubmit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Your Feedback',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us improve ${widget.program.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),

                // Program Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.program.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.program.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Feedback Category Dropdown
                Text(
                  'What type of feedback is this?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _feedbackCategory,
                  decoration: const InputDecoration(
                    hintText: 'Select a category',
                  ),
                  items: _feedbackCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) => setState(() {
                            _feedbackCategory = value;
                            if (_errorMessage != null && value != null) {
                              _errorMessage = null;
                            }
                          }),
                  validator: _validateCategory,
                ),
                const SizedBox(height: 28),

                // Rating Stars
                Text(
                  'How would you rate this program?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () => setState(() {
                        _rating = index + 1;
                        if (_errorMessage != null && _rating > 0) {
                          _errorMessage = null;
                        }
                      }),
                      child: Icon(
                        Icons.star,
                        size: 40,
                        color: index < _rating
                            ? AppTheme.primaryOrange
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_rating > 0)
                  Text(
                    '$_rating out of 5 stars',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                const SizedBox(height: 28),

                // Feedback Text Area
                Text(
                  'What could we improve?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts...',
                    enabled: !_isLoading,
                  ),
                  maxLines: 5,
                  validator: _validateFeedback,
                ),
                const SizedBox(height: 28),

                // Error Message (validation or submission failure)
                if (_errorMessage != null) ...[
                  InlineErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 20),
                ],

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmitFeedback,
                    child: _isLoading
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
                        : const Text('Submit Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
