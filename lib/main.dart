import 'package:emc_mob/providers/check_in_provider.dart';
import 'package:emc_mob/providers/emotion_provider.dart';
import 'package:emc_mob/providers/employee_provider.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/screens/splash/animated_splash_screen.dart';
import 'package:emc_mob/utils/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emc_mob/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the SQLite database before the app starts.
  await DatabaseHelper.instance.database;

  final loginProvider = LoginProvider();
  final checkInProvider = CheckInProvider();

  /// Check if the user has a valid authentication token.
  bool isUserLoggedIn = await loginProvider.ensureValidToken();

  /// If the user is logged in, load check-in records from the local database.
  if (isUserLoggedIn) {
    await loginProvider.restoreUserInfo();
    await checkInProvider.loadCheckInsFromDB();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => loginProvider),
        ChangeNotifierProvider(create: (_) => checkInProvider),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATA - Emotion Check-in Application',
      theme: EAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AnimatedSplashScreen(),
    );
  }
}