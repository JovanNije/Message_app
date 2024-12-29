import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginScreen.dart';
import 'ChatScreen.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the configuration from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // This handles the platform-specific initialization
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Login',
      home: LoginScreen(),
    );
  }
}

