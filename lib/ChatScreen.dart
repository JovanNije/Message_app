import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure that you have your firebase_options.dart imported

class ChatScreen extends StatefulWidget {
  final String email; // Email passed from LoginScreen
  final String username; // Username passed from LoginScreen or generated

  const ChatScreen({super.key, required this.email, required this.username});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false; // Flag to track if the user is typing
  String _typingUser = ''; // The user who is typing

  late DatabaseReference _messagesRef;

  // Method to get username from email if username is null
  String getUsername() {
    if (widget.username == 'User') {
      return widget.email.split('@')[0]; // Get the part before '@'
    } else {
      return widget.username;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _messagesRef = FirebaseDatabase.instance
        .ref('messages'); // Reference to the messages node
  }

  // Called when the focus changes (user starts typing or stops)
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isTyping = true; // Show typing indicator when focused
        _typingUser = getUsername(); // Set typing user
      });
    } else {
      setState(() {
        _isTyping = false; // Hide typing indicator when focus is lost
        _typingUser = ''; // Reset typing user
      });
    }
  }

  // Send message to Firebase
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Send message to Firebase Realtime Database
      _messagesRef.push().set({
        'username': getUsername(),
        'message': _controller.text,
        'timestamp': ServerValue.timestamp,
      });

      _controller.clear(); // Clear text after sending
      setState(() {
        _isTyping = false; // Hide typing indicator after sending
        _typingUser = ''; // Reset typing user after sending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName =
        getUsername(); // Get the username or fallback to email part

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 92, 87),
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
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _messagesRef
                    .orderByChild('timestamp')
                    .onValue, // Make sure messages are ordered by timestamp
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Safely cast snapshot.data!.snapshot.value to Map
                  Map<dynamic, dynamic> messages = {};
                  if (snapshot.data!.snapshot.value != null) {
                    messages = Map.from(snapshot.data!.snapshot.value
                        as Map); // Safely cast to Map
                  }

                  // Convert the messages into a list of widgets
                  List<Widget> messageWidgets = [];
                  messages.forEach((key, value) {
                    messageWidgets.add(MessageBubble(
                      message: value['message'],
                      isMe: value['username'] == displayName,
                      username: value['username'],
                    ));
                  });

                  // Add typing indicator if the user is typing
                  if (_isTyping) {
                    messageWidgets.insert(
                        0,
                        MessageBubble(
                          message: '$_typingUser is typing...',
                          isMe: false,
                          isTypingIndicator: true,
                          username: _typingUser,
                        ));
                  }

                  return ListView(
                    // Remove reverse: true to show new messages at the bottom
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
                      focusNode:
                          _focusNode, // Attach focus node to the TextField
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Color(0xFF757575)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 231, 92, 87)),
                        ),
                      ),
                      onChanged: (text) {
                        // If text is entered, show typing indicator
                        setState(() {
                          _isTyping = text.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Color.fromARGB(255, 231, 92, 87)),
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

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isTypingIndicator; // Flag to check if it's a typing indicator
  final String username; // Username of the person who sent the message

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isTypingIndicator =
        false, // Default to false, unless it's a typing indicator
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isTypingIndicator
              ? const Color(0xFFF5F7FA) // Light background for typing indicator
              : (isMe
                  ? const Color.fromARGB(255, 243, 143, 139)
                  : const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the username above the message
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ),
            // Display the message content
            Text(
              message,
              style: TextStyle(
                color: isTypingIndicator
                    ? const Color(0xFF757575) // Dark grey for typing indicator
                    : (isMe
                        ? const Color(0xFF212121)
                        : const Color(0xFF212121)),
                fontStyle: isTypingIndicator
                    ? FontStyle.italic
                    : FontStyle.normal, // Italics for typing indicator
              ),
            ),
          ],
        ),
      ),
    );
  }
}
