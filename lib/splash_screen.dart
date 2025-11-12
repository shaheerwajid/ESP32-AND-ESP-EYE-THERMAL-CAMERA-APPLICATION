import 'dart:async';
import 'package:flutter/material.dart';
import 'animated_splash.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnimatedSplashScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints.expand(), // Fill entire screen
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/LOGO.jfif'),
              fit: BoxFit.fill, // Show full image maintaining aspect ratio
            ),
          ),
        ),
      ),
    );
  }
}