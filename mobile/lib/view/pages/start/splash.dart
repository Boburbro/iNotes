import 'package:flutter/material.dart';
import '../../widgets/opacity_animator.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: OpacityAnimator(
          beginingOpacity: 0.2,
          child: Image.asset(
            'assets/placeholder_avatar.png',
            height: 250,
            key: const Key('inotes'),
          ),
        ),
      ),
    );
  }
}
