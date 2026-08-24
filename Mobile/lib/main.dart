import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/program_details_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/enrollment_screen.dart';
import 'screens/feedback_screen.dart';
import 'theme/app_theme.dart';
import 'models/program.dart';

void main() {
  runApp(const ExcelerateApp());
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
          final program = ModalRoute.of(context)!.settings.arguments as Program;
          return ProgramDetailsScreen(program: program);
        },
        '/registration': (context) => const RegistrationScreen(),
        '/enrollment': (context) {
          final program = ModalRoute.of(context)!.settings.arguments as Program;
          return EnrollmentScreen(program: program);
        },
        '/feedback': (context) {
          final program = ModalRoute.of(context)!.settings.arguments as Program;
          return FeedbackScreen(program: program);
        },
      },
    );
  }
}
