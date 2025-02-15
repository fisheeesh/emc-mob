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

/// The entry point of the ATA-EmotionCheck-in application.
///
/// This method initializes essential services, checks user authentication status,
/// and determines the appropriate starting screen before launching the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the SQLite database before the app starts.
  await DatabaseHelper.instance.database;

  /// Retrieve shared preferences to check if the onboarding screen has been viewed.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getInt('onBoard');

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
      ],
      child: MyApp(isUserLoggedIn: isUserLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  MyApp({super.key, required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATA - Emotion Check-in Application',
      theme: EAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isViewed != 0
          ? OnBoardingScreen()
          : isUserLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
