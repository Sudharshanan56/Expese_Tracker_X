import 'package:expense_tracker_x/Authentication/signup.dart';
import 'package:expense_tracker_x/Budget/budget.dart';
import 'package:expense_tracker_x/Calender/calender.dart';
import 'package:expense_tracker_x/Goal/goal.dart';
import 'package:expense_tracker_x/Home/home_screen.dart';
import 'package:expense_tracker_x/Insight/insight.dart';
import 'package:expense_tracker_x/Navigation/navigation.dart';
import 'package:expense_tracker_x/Splash%20Screen/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDwfpky0rfiMje-egeuBkIA5g3H4LgGzMs",
        authDomain: "expense-tracker-x-debcd.firebaseapp.com",
        projectId: "expense-tracker-x-debcd",
        storageBucket: "expense-tracker-x-debcd.firebasestorage.app",
        messagingSenderId: "425658436898",
        appId: "1:425658436898:web:4b641546479911331ca97b",
        measurementId: "G-HFEPTXG8Q5",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? SplashScreen() : SignupScreen(),
    );
  }
}
