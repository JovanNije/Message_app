import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:messeging_app/app.dart';

class ChatScreen extends StatefulWidget {
  final String email;
  final String username;

  const ChatScreen({super.key, required this.email, required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ValueNotifier<bool> _isTypingNotifier = ValueNotifier<bool>(false);
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String _typingUser = '';
  String get email => widget.email;
  String get username => widget.username;

  late DatabaseReference _messagesRef;

  // Initialize Firebase and check if the user is logged in on app start
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _messagesRef = FirebaseDatabase.instance.ref('messages');
    _checkSession();
    // Initial scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    // If the session is not valid, navigate back to the LoginScreen
    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _isTypingNotifier.value = true;
      _typingUser = getUsername();
    } else {
      _isTypingNotifier.value = false;
      _typingUser = '';
    }
  }

  String getUsername() {
    if (widget.username == 'User') {
      return widget.email.split('@')[0];
    } else {
      return widget.username;
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _messagesRef.push().set({
        'username': getUsername(),
        'message': _controller.text,
        'timestamp': ServerValue.timestamp,
        'userImage': 'assets/images/profile_picture.jpg',
      });

      _controller.clear();
      setState(() {
        _isTyping = false;
        _typingUser = '';
      });

      // Scroll to bottom after sending a message
      _scrollToBottom();
    }
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    // Scroll to the bottom after a message is sent or the list is updated
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

Future<void> _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);  // Clear the login status
  await prefs.remove('email'); // Optionally clear the email and username
  await prefs.remove('username'); // Optionally clear the username

  // Sign out the user
  await FirebaseAuth.instance.signOut();

  // Navigate back to login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),  // Use the direct screen route
  );
}


  @override
  Widget build(BuildContext context) {
    String displayName = getUsername();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 87, 176),
        elevation: 2.0,
        shadowColor: const Color(0x1A000000),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout, // Logout on tap
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_picture.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _messagesRef.orderByChild('timestamp').onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  Map<dynamic, dynamic> messages = {};
                  if (snapshot.data!.snapshot.value != null) {
                    messages = Map.from(snapshot.data!.snapshot.value as Map);
                  }

                  List<Widget> messageWidgets = [];
                  messages.forEach((key, value) {
                    String message = value['message'] ?? '';
                    String username = value['username'] ?? 'Anonymous';
                    String userImage = value['userImage'] ?? 'assets/images/default_profile.jpg';

                    messageWidgets.add(MessageBubble(
                      message: message,
                      isMe: username == getUsername(),
                      username: username,
                      userImage: userImage,
                    ));
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView(
                    controller: _scrollController,
                    reverse: false,
                    children: messageWidgets,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Color(0xFF757575)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 231, 92, 87)),
                        ),
                      ),
                      onChanged: (text) {
                        if (text.isNotEmpty && !_isTyping) {
                          _isTypingNotifier.value = true;
                          _typingUser = getUsername();
                        } else if (text.isEmpty && _isTyping) {
                          _isTypingNotifier.value = false;
                          _typingUser = '';
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color.fromARGB(255, 201, 87, 176)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
