import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? token;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get device token
    token = await messaging.getToken();
    print("FCM Token: $token");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
    });

    // When app opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App opened from terminated: ${message.notification?.title}");
      }
    });

    // When app is in background and opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App opened from background: ${message.notification?.title}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Push Notifications")),
      body: Center(
        child: Text("FCM Token:\n$token"),
      ),
    );
  }
}
