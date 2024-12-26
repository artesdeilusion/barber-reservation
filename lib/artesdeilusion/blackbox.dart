import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:html' as html;
 

class BlackBox extends StatefulWidget {
  @override
  _BlackBoxState createState() => _BlackBoxState();
}

class _BlackBoxState extends State<BlackBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _openURL() async {
    const url = 'https://artesdeilusion.com';
    try {
      html.window.open(url, '_blank'); // Opens the URL in a new tab
    } catch (e) {
      throw 'Could not launch $url: $e';
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openURL,
      child: MouseRegion(
        onEnter: (_) {
          _controller.repeat();
        },
        onExit: (_) {
          _controller.stop();
          _controller.reset();
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 2 * math.pi, // 2*π radians
              child: child,
            );
          },
          child: Container(
            width: 35,
            height: 35,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}