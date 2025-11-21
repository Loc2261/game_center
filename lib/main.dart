import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/cubic_solver_provider.dart';
import 'services/api_service.dart';
import 'services/leaderboard_api_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/caro_game_screen.dart';
import 'screens/cubic_solver_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'games/puzzle/screens/puzzle_setup_screen.dart';
import 'widgets/game/game_history_widget.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'games/tetris/screens/tetris_launcher_screen.dart';
void main() {
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => GameProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => LeaderboardProvider(LeaderboardApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => CubicSolverProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Game Center',
        theme: AppTheme.darkTheme, // Use dark theme
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Force dark mode
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/caro': (context) => const CaroGameScreen(),
          '/cubic-solver': (context) => const CubicSolverScreen(),
          '/tetris': (context) => const TetrisLauncherScreen(),
          '/puzzle_setup': (context) => const PuzzleSetupScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/history': (context) => const GameHistoryScreen(),
        },
      ),
    );
  }
}