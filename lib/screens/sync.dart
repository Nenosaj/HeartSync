import 'package:flutter/material.dart';

class Sync extends StatelessWidget {
  final Function onPressed;
    final String label; // New: Dynamic label


  const Sync({super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300  ,
      child: ElevatedButton(
        onPressed: () => onPressed(), // Function to handle the button press
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
