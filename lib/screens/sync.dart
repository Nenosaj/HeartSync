import 'package:flutter/material.dart';

class Sync extends StatelessWidget {
  final bool isConnected; // Connection state passed from parent
  final Function() onPressed; // Callback for button press

  const Sync({
    super.key,
    required this.onPressed,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected ? Colors.blue : Colors.pink, // Optional color change
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          isConnected ? "DESYNC" : "SYNC", // Display text based on connection state
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
