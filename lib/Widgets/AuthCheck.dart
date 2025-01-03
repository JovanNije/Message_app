import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:messeging_app/app.dart'; // Adjust this import based on your app's file structure

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late bool isLoggedIn = false;
  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Check if the user is already logged in
  void _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Retrieve email and username from SharedPreferences
    email = prefs.getString('email') ?? '';
    username = prefs.getString('username') ?? '';

    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If user is logged in, navigate to the ChatScreen with email and username
    if (isLoggedIn) {
      return ChatScreen(
        email: email,      // Pass the actual email
        username: username // Pass the actual username
      );
    } else {
      return LoginScreen(); // Show login screen if not logged in
    }
  }
}
