import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/providers/auth_provider.dart';
import 'state/providers/course_provider.dart';
import 'state/providers/category_provider.dart';
import 'state/providers/video_provider.dart';
import 'state/providers/recruitment_provider.dart';
import 'state/providers/learning_provider.dart';
import 'state/providers/notification_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/learning/courses_list_screen.dart';
import 'presentation/screens/learning/my_courses_screen.dart';
import 'presentation/screens/learning/categories_screen.dart';
import 'presentation/screens/learning/video_library_screen.dart';
import 'presentation/screens/learning/enrollments_screen.dart';
import 'presentation/screens/learning/quiz_checkpoints_screen.dart';
import 'presentation/screens/learning/quiz_history_screen.dart';
import 'presentation/screens/learning/progress_screen.dart';
import 'presentation/screens/recruitment/job_postings_screen.dart';
import 'presentation/screens/recruitment/candidates_list_screen.dart';
import 'presentation/screens/recruitment/job_descriptions_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
      ],
      child: MaterialApp(
        title: 'HRMS Frontend',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          
          // LMS Routes
          '/courses': (context) => const CoursesListScreen(),
          '/my-courses': (context) => const MyCoursesScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/videos': (context) => const VideoLibraryScreen(),
          '/enrollments': (context) => const EnrollmentsScreen(),
          '/quiz-checkpoints': (context) => const QuizCheckpointsScreen(),
          '/quiz-history': (context) => const QuizHistoryScreen(),
          '/progress': (context) => const ProgressScreen(),
          
          // Recruitment Routes
          '/job-postings': (context) => const JobPostingsScreen(),
          '/candidates': (context) => const CandidatesListScreen(),
          '/job-descriptions': (context) => const JobDescriptionsScreen(),
          
          // Notifications
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}

/// Initializes the app and handles authentication state
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while initializing
        if (authProvider.state == AuthState.initial ||
            authProvider.state == AuthState.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on auth state
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
