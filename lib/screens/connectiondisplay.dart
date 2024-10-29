import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  

  const ConnectionStatus({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30), // Adjust padding as needed
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(30), // Rounded edges
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps the content without taking full width
        children: [
          // SizedBox ensures the width is fixed and won't change based on text length
          SizedBox(
            width: 200, // Set a fixed width for the text
            child: Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800], // Text color
              ),
              textAlign: TextAlign.left, // Align text to the left
            ),
          ),
          const SizedBox(width: 50), // Space between text and circle
          
          // Icon to represent connection status (Green = connected, Red = disconnected)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red, // Color based on status
              shape: BoxShape.circle, // Circle shape
            ),
          ),
        ],
      ),
    );
  }
}
