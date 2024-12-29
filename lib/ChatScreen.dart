import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String email; // Email passed from LoginScreen
  final String username; // Username passed from LoginScreen or generated

  const ChatScreen({super.key, required this.email, required this.username}); // Accept email and username

  // Method to get username from email if username is null
  String getUsername() {
    if (username == 'User') {
       return email.split('@')[0]; // Get the part before '@'
    } else {
      // If username is empty, use the part of the email before '@'
      return username;
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName = getUsername(); // Get the username or fallback to email part

    return Scaffold(
appBar: AppBar(
    backgroundColor: const Color.fromARGB(255, 231, 92, 87), // Primary Background
    elevation: 2.0,
    shadowColor: const Color(0x1A000000), // Shadow
    iconTheme: const IconThemeData(color: Colors.white), // Icon color

    // Leading icon and username in the AppBar
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.person, color: Colors.white), // Icon Placeholder
      ),
    ),
    
    // Adding the username (displayName) next to the icon
    title: Padding(
      padding: const EdgeInsets.only(left: 8.0), // Adjust the padding for alignment
      child: Text(
        displayName, // Display the username next to the icon
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
      ),
    ],
  ),
      body: Container(
        color: const Color(0xFFF5F7FA), // Primary Background
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: 10, // Placeholder for messages count
                itemBuilder: (context, index) {
                  return MessageBubble(
                    message: 'Message $index',
                    isMe: index % 2 == 0,
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA), // Input Field Background
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Color(0xFF757575)), // Secondary Text
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 231, 92, 87)), // Input Field Border
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color.fromARGB(255, 231, 92, 87)), // Fresh Green
                    onPressed: () {
                      // Add message sending logic here
                    },
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

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe ? const Color.fromARGB(255, 243, 143, 139) : const Color(0xFFFFFFFF), // Sent/Received Bubble Colors
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          border: Border.all(color: const Color(0xFFE0E0E0)), // Border
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // Shadow
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? const Color(0xFF212121) : const Color(0xFF212121)), // Primary Text
        ),
      ),
    );
  }
}
