import 'package:brainfood/screens/introduction_screen.dart';
import 'package:brainfood/screens/nav_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateListener extends StatelessWidget {
  const AuthStateListener({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const NavigationScreen();
        } else {
          return const IntroductionScreen();
        }
      },
    ));
  }
}
