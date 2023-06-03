import 'package:brainfood/screens/login_screen.dart';
import 'package:brainfood/screens/nav_screen.dart';
import 'package:brainfood/screens/signup_screen.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  bool _isLoading = false;

  void openLoginScreen() {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const LoginScreen(),
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  void openSignupScreen() {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const SignUpScreen(),
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  void openHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NavigationScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  void anonymousLogin() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods().signInAnonymously();

    if (res == "success") {
      //success
      openHomePage();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      showSnackBar(res, context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(-width * 1.1, 0),
              blurRadius: 100,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.1,
              ),
              Image.asset('assets/study.png'),
              const Text(
                'Hey! Welcome',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Our goal is to deliver you the useful tools needed during the college years in one place.',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              MyTextButton(
                text: 'Get Started',
                onPressed: () {
                  openSignupScreen();
                },
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(149, 117, 205, 1),
                    Color.fromRGBO(247, 86, 114, 1),
                  ],
                ),
              ),
              MyTextButton(
                text: 'Already have an account',
                onPressed: () {
                  openLoginScreen();
                },
                boxcolor: Colors.white,
                textcolor: Colors.black,
              ),
              // MyTextButton(
              //   text: 'Guest login',
              //   onPressed: () {
              //     //anonymousLogin();
              //   },
              //   boxcolor: Colors.white,
              //   textcolor: Colors.black,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
