import 'package:expense_tracker_x/Authentication/signup.dart';
import 'package:expense_tracker_x/Budget/budget.dart';
import 'package:expense_tracker_x/Goal/goal.dart';
import 'package:expense_tracker_x/Home/home_screen.dart';
import 'package:expense_tracker_x/Insight/insight.dart';
import 'package:expense_tracker_x/Navigation/navigation.dart';
import 'package:expense_tracker_x/Splash%20Screen/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SignupScreen(),
    );
  }
}
