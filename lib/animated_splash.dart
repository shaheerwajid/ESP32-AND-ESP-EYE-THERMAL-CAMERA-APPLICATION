import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _letterAnimation;
  late Animation<double> _poweredByAnimation;
  late Animation<double> _orbitAnimation;
  late Animation<double> _eosAnimation;
  late Animation<double> _orbitRadiusAnimation;
  late Animation<double> _innerOrbitAnimation;
  late Animation<double> _innerOrbitRadiusAnimation;

  final double _initialOrbitRadius = 180.0;
  final double _initialInnerOrbitRadius = 140.0; // Reduced initial radius for inner orbit

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 7 ),
    );

    _letterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _eosAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _poweredByAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _orbitAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _innerOrbitAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    // Adjusted the final radius for the inner orbit to avoid overlap
    _orbitRadiusAnimation = Tween<double>(begin: _initialOrbitRadius, end: 260.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _innerOrbitRadiusAnimation = Tween<double>(begin: _initialInnerOrbitRadius, end: 220.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _navigateToMainScreen();
        }
      });
    });
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LEOSController()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final centerY = constraints.maxHeight / 2;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: _letterAnimation.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Transform.translate(
                                offset: Offset(_eosAnimation.value, 0),
                                child: Text(
                                  'EOS',
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Opacity(
                          opacity: _poweredByAnimation.value.clamp(0.0, 1.0),
                          child: Text(
                            'Powered by Artificial Intelligence',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._buildOuterCircularText(centerX, centerY),
                  ..._buildInnerCircularText(centerX, centerY),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOuterCircularText(double centerX, double centerY) {
    String outerText = "Laser &  Electro Optical Solutions • Laser &  Electro Optical Solutions •";
    double totalAngle = 2 * pi;
    double angleStep = totalAngle / outerText.length;

    List<Widget> letters = [];

    for (int i = 0; i < outerText.length; i++) {
      double angle = _orbitAnimation.value + (i * angleStep);
      double x = centerX + _orbitRadiusAnimation.value * cos(angle);
      double y = centerY + _orbitRadiusAnimation.value * sin(angle);

      letters.add(
        Positioned(
          left: x,
          top: y,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-5.0, -5.0)
              ..rotateZ(angle + pi / 2),
            child: Text(
              outerText[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return letters;
  }

  List<Widget> _buildInnerCircularText(double centerX, double centerY) {
    String innerText = " . Artificial Intelligence . Image Fusion Device . Thermal Camera . Missile Seeker . Laser Device";
    double totalAngle = 2 * pi;
    double angleStep = totalAngle / innerText.length;

    List<Widget> letters = [];

    for (int i = 0; i < innerText.length; i++) {
      double angle = _orbitAnimation.value + (i * angleStep);
      double x = centerX + _innerOrbitRadiusAnimation.value * cos(angle);
      double y = centerY + _innerOrbitRadiusAnimation.value * sin(angle);

      letters.add(
        Positioned(
          left: x,
          top: y,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-5.0, -5.0)
              ..rotateZ(angle + pi / 2),
            child: Text(
              innerText[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return letters;
  }
}
