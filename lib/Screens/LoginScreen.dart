import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:messeging_app/app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Initialize Firebase
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _checkSession();
  }

  // Initialize Firebase
  void _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print("Firebase initialization failed: $e");
    }
  }

// Check if the user is already logged in
void _checkSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    // Retrieve the email and username from SharedPreferences
    String email = prefs.getString('email') ?? '';
    String username = prefs.getString('username') ?? 'User';

    // If the user is logged in, navigate directly to the ChatScreen with email and username
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          email: email,       // Pass the email
          username: username, // Pass the username
        ),
      ),
    );
  }
}

void _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Try to sign in with email and password
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Fetch username from Firestore (or use displayName if available)
    final user = userCredential.user;
    String username = user?.displayName ?? 'User'; // If displayName is empty, use 'User'

    // Store email and username in SharedPreferences after login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);  // Set login status
    await prefs.setString('email', user!.email!);    // Save email
    await prefs.setString('username', username); // Save username

    // Pass the email and username to ChatScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          email: user.email!, // Pass the email
          username: username, // Pass the username
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    print("Error Code: ${e.code}");
    print("Error Message: ${e.message}");

    String message = 'An error occurred, please try again.';
    if (e.code == 'user-not-found') {
      message = 'No user found with this email.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    } else {
      message = 'Error: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 243, 225), // Primary Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121), // Primary Text
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 231, 92, 87)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 231, 92, 87)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 231, 92, 87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/register');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    color: Color.fromARGB(255, 231, 92, 87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
