import 'package:flutter/material.dart';

class HeartDisplay extends StatefulWidget {
  final int heartRate;
  final bool isAnimating; // Add a new prop to control animation

  const HeartDisplay({
    super.key,
    required this.heartRate,
    required this.isAnimating, // Pass the control for animation start/stop
  });

  @override
  HeartDisplayState createState() => HeartDisplayState();
}

class HeartDisplayState extends State<HeartDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation1;
  late Animation<double> _opacityAnimation2;
  late Animation<double> _opacityAnimation3;
  late Animation<double> _opacityAnimation4;

  @override
  void initState() {
    super.initState();

    // AnimationController that will be controlled later by isAnimating
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animations for each concentric circle with staggered delays
    _opacityAnimation1 = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _opacityAnimation2 = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7)),
    );
    _opacityAnimation3 = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9)),
    );
    _opacityAnimation4 = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );
  }

  @override
  void didUpdateWidget(covariant HeartDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start or stop the animation based on the isAnimating prop
    if (widget.isAnimating) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 329,
        decoration: BoxDecoration(
          color: Colors.white, // Background color to match the card
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // First concentric shape with lowest opacity
            Positioned(
              top: 40, // Adjusted to move all concentric shapes upwards
              child: AnimatedBuilder(
                animation: _opacityAnimation1,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation1.value,
                    child: Container(
                      width: 100,
                      height: 144,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.5, color:  Color(0xFF797D86)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Second concentric shape
            Positioned(
              top: 26,
              child: AnimatedBuilder(
                animation: _opacityAnimation2,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation2.value,
                    child: Container(
                      width: 124,
                      height: 172,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.5, color: Color(0xFF797D86)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Third concentric shape
            Positioned(
              top: 12,
              child: AnimatedBuilder(
                animation: _opacityAnimation3,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation3.value,
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.5, color:  Color(0xFF797D86)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Fourth concentric shape
            Positioned(
              top: 0,
              child: AnimatedBuilder(
                animation: _opacityAnimation4,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation4.value,
                    child: Container(
                      width: 172,
                      height: 224,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.5, color: Color(0xFF797D86)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Capsule-like shape (centered and black/pink)
            Positioned(
              top: 54,
              child: Column(
                children: [
                  // Top black part of the capsule
                  Container(
                    width: 75,
                    height: 58.38, // Half of 116.76
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B3A3B), // Black color
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                  ),
                  // Bottom pink part of the capsule
                  Container(
                    width: 75,
                    height: 58.38,
                    decoration: const BoxDecoration(
                      color: Colors.pink, // Pink color
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Heart rate text display at the bottom of the Stack
            Positioned(
              bottom: 30,
              child: Column(
                children: [
                  Text(
                    '${widget.heartRate} bpm',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Heart Rate',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
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
