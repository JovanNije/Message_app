import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isTypingIndicator;
  final String username;
  final String userImage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isTypingIndicator = false,
    required this.username,
    required this.userImage, // Path to the image
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 4), // White outline
          color: isTypingIndicator
              ? const Color(0xFFF5F7FA) 
              : (isMe
                  ? const Color.fromARGB(255, 237, 177, 245)
                  : const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: isMe ? const Radius.circular(24) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User's profile image
            CircleAvatar(
              radius: 40, 
              backgroundImage: AssetImage(userImage),
            ),
            const SizedBox(width: 20),
            // Message text container
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,  // Larger font size for username
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16, // Normal font size for the message
                    fontFamily: 'CourierNew', // Change to a cool font style
                    color: isTypingIndicator
                        ? const Color(0xFF757575)
                        : (isMe
                            ? const Color(0xFF212121)
                            : const Color(0xFF212121)),
                    fontStyle: isTypingIndicator
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
