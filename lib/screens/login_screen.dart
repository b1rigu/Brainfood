import 'package:brainfood/screens/forgot_pass_screen.dart';
import 'package:brainfood/screens/nav_screen.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

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

  void openHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NavigationScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  void openForgotPassScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForgotPassScreen(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            const Center(
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: height * 0.07,
            ),
            MyTextField(
              keyboardType: TextInputType.emailAddress,
              labelText: 'Email address',
              hintText: 'name@example.com',
              controller: _emailController,
              onpressX: () {
                _emailController.clear();
              },
            ),
            MyTextField(
              top: 24.0,
              keyboardType: TextInputType.text,
              labelText: 'Password',
              hintText: 'at least 6 characters',
              controller: _passwordController,
              ispass: true,
              onpressX: () {
                _passwordController.clear();
              },
            ),
            SizedBox(
              height: height * 0.04,
            ),
            MyTextButton(
              text: 'Login',
              onPressed: () {
                loginUser();
              },
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromRGBO(247, 86, 114, 1),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                openForgotPassScreen();
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                    color: Color.fromRGBO(149, 117, 205, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(
                thickness: 2.0,
              ),
            ),
            MyTextButton(
              text: 'Continue with Google',
              onPressed: () {},
              boxcolor: Colors.white,
              textcolor: Colors.black,
              icon: 'assets/google_icon.png',
            ),
          ],
        ),
      ),
    );
  }
}
