import 'package:flutter/material.dart';

class HeartSyncIcon extends StatelessWidget {
  const HeartSyncIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, // Adjust width as needed
      height: 30, // Adjust height as needed
      decoration: BoxDecoration(
        color: Colors.grey[200], // Set the background color
      ),
      child: Image.asset(
        'assets/Group 8.png', // Path to the image in assets
        fit: BoxFit.contain, // Ensure the image fits nicely within the container
      ),
    );
  }
}

