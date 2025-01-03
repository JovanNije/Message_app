import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the configuration from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // This handles the platform-specific initialization
  );

  // Get a reference to the Realtime Database
  final database = FirebaseDatabase.instance;
  final DatabaseReference ref =
      database.ref(); // Root reference of the database

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messaging App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(), // Start the app with AuthCheck widget
      initialRoute: '/',
      routes: {
        '/LoginScreen': (context) => LoginScreen(),
        // Other routes
      },
    );
  }
}

class GestureDetector extends StatefulWidget {
  const GestureDetector({super.key});

  @override
  _GestureDetectorState createState() => _GestureDetectorState();
}

class _GestureDetectorState extends State<GestureDetector> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
