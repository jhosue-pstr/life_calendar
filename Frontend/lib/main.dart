import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/activity_service.dart';
import 'services/goal_service.dart';
import 'services/bad_habit_service.dart';
import 'services/contribution_service.dart';
import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/bad_habit_provider.dart';
import 'providers/contribution_provider.dart';
import 'screens/login_screen.dart';
import 'calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final activityService = ActivityService(apiClient);
    final goalService = GoalService(apiClient);
    final badHabitService = BadHabitService(apiClient);
    final contributionService = ContributionService(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(activityService),
        ),
        ChangeNotifierProvider(create: (_) => GoalProvider(goalService)),
        ChangeNotifierProvider(
          create: (_) => BadHabitProvider(badHabitService),
        ),
        ChangeNotifierProvider(
          create: (_) => ContributionProvider(contributionService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Life Calendar',
        theme: ThemeData.dark(),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading || auth.status == AuthStatus.unknown) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return const CalendarPage();
        }

        return const LoginScreen();
      },
    );
  }
}
