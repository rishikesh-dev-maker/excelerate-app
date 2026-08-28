import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/program_details_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/enrollment_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'theme/app_theme.dart';
import 'models/program.dart';
import 'providers/session_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: const ExcelerateApp(),
    ),
  );
}
class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/programs': (context) => const ProgramsScreen(),
        '/program-details': (context) {
          final program = ModalRoute.of(context)!.settings.arguments;
          return program is Program
              ? ProgramDetailsScreen(program: program)
              : const ProgramsScreen();
        },
        '/registration': (context) => const RegistrationScreen(),
        '/enrollment': (context) {
          final program = ModalRoute.of(context)!.settings.arguments;
          return program is Program
              ? EnrollmentScreen(program: program)
              : const ProgramsScreen();
        },
        '/feedback': (context) {
          final program = ModalRoute.of(context)!.settings.arguments;
          return program is Program
              ? FeedbackScreen(program: program)
              : const ProgramsScreen();
        },
        '/progress': (context) => const ProgressScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
