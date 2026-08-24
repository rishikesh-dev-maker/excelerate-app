import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/program.dart';
import '../repositories/auth_repository.dart';
import '../repositories/enrollment_repository.dart';
import '../widgets/state_views.dart';

class EnrollmentScreen extends StatefulWidget {
  final Program program;

  const EnrollmentScreen({Key? key, required this.program}) : super(key: key);

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final EnrollmentRepository _enrollmentRepository = EnrollmentRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _interestController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateInterest(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please tell us why you\'re interested';
    }
    if (value.trim().length < 10) {
      return 'Please provide more detail (at least 10 characters)';
    }
    return null;
  }

  void _handleEnrollment() async {
    setState(() {
      _errorMessage = null;
      _hasAttemptedSubmit = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        throw StateError('Please sign in before enrolling.');
      }
      await _enrollmentRepository.enroll(
        userId: userId,
        programId: widget.program.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        interest: _interestController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enrollment Successful! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to ${widget.program.title}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                  'Hi ${_nameController.text}, we\'ve sent a confirmation to ${_emailController.text}.'),
              const SizedBox(height: 12),
              const Text('You can now start learning. Good luck! 🚀'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Start Learning'),
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
                  'Enroll in Program',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.program.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

                // Full Name Field
                Text(
                  'Full Name',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Your full name',
                    enabled: !_isLoading,
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 20),

                // Email Field
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    enabled: !_isLoading,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                // Interest Text Area
                Text(
                  'Why are you interested in this program?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _interestController,
                  decoration: InputDecoration(
                    hintText: 'Tell us what excites you about this program...',
                    enabled: !_isLoading,
                  ),
                  maxLines: 4,
                  validator: _validateInterest,
                ),
                const SizedBox(height: 28),

                // Submission Error Banner
                if (_errorMessage != null) ...[
                  InlineErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 20),
                ],

                // Enroll Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEnrollment,
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
                        : Text(_errorMessage != null
                            ? 'Retry Enrollment'
                            : 'Confirm Enrollment'),
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
