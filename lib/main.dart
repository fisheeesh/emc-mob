import 'package:emotion_check_in_app/demo/emotion_check_in_provider.dart';
import 'package:emotion_check_in_app/provider/check_in_provider.dart';
import 'package:emotion_check_in_app/provider/login_provider.dart';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/screens/main/home_screen.dart';
import 'package:emotion_check_in_app/screens/onBoard/on_boarding_screen.dart';
import 'package:emotion_check_in_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emotion_check_in_app/database/database_helper.dart';

int? isViewed;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ Initialize Database Properly
  await DatabaseHelper.instance.database; // Ensures DB and tables are ready

  /// ✅ Load SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getInt('onBoard');

  final loginProvider = LoginProvider();
  final checkInProvider = CheckInProvider();

  /// ✅ Check if user session is valid
  bool isUserLoggedIn = await loginProvider.ensureValidToken();
  await loginProvider.restoreUserInfo();

  /// ✅ Load Check-Ins from SQLite (if logged in)
  if (isUserLoggedIn) {
    await checkInProvider.loadCheckInsFromDB();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => loginProvider),
        ChangeNotifierProvider(create: (_) => EmotionCheckInProvider()),
        ChangeNotifierProvider(create: (_) => checkInProvider),
      ],
      child: MyApp(isUserLoggedIn: isUserLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  const MyApp({super.key, required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATA - Emotion Check-in Application',
      theme: EAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isViewed != 0 ? OnBoardingScreen() : isUserLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}