import 'dart:typed_data';
import 'package:brainfood/screens/login_screen.dart';
import 'package:brainfood/screens/nav_screen.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/pick_image.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods().signUpUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmpass: _confirmPasswordController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      if (!mounted) return;
      showSnackBar(res, context, true);
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const SecondSignupScreen(),
          duration: const Duration(milliseconds: 100),
          reverseDuration: const Duration(milliseconds: 100),
        ),
      );
    }
  }

  void openLoginPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
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
                'Create an account',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
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
            MyTextField(
              top: 24.0,
              keyboardType: TextInputType.text,
              labelText: 'Confirm Password',
              hintText: 'at least 6 characters',
              controller: _confirmPasswordController,
              ispass: true,
              onpressX: () {
                _confirmPasswordController.clear();
              },
            ),
            SizedBox(
              height: height * 0.04,
            ),
            MyTextButton(
              text: 'Create an account',
              onPressed: () {
                signUpUser();
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
                openLoginPage();
              },
              child: const Text(
                'Already have account?',
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

class SecondSignupScreen extends StatefulWidget {
  const SecondSignupScreen({Key? key}) : super(key: key);

  @override
  State<SecondSignupScreen> createState() => _SecondSignupScreenState();
}

class _SecondSignupScreenState extends State<SecondSignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods().signUpUser(
      secondScreen: true,
      username: _usernameController.text,
      file: _image,
    );

    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      if (!mounted) return;
      showSnackBar(res, context, true);
    } else {
      if (!mounted) return;
      openHomePage();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  void openHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NavigationScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  void selectImage() async {
    Uint8List? im;
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(IconlyLight.camera),
              title: const Text('Select using camera'),
              onTap: () async {
                im = await pickImage(true, false);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(IconlyLight.category),
              title: const Text('Select from gallery'),
              onTap: () async {
                im = await pickImage(true, true);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (_image != null && im == null) {
      //nothing
    } else {
      setState(() {
        _image = im;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Setup profile',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: height * 0.07,
            ),
            selectprofilepic(),
            SizedBox(
              height: height * 0.07,
            ),
            MyTextField(
              keyboardType: TextInputType.text,
              labelText: 'Username',
              hintText: 'I_love_brainfood',
              controller: _usernameController,
              onpressX: () {
                _usernameController.clear();
              },
            ),
            SizedBox(
              height: height * 0.03,
            ),
            MyTextButton(
              text: 'Continue',
              onPressed: () {
                signUpUser();
              },
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromRGBO(247, 86, 114, 1),
                ],
              ),
            ),
            MyTextButton(
              text: 'Setup later',
              onPressed: () {
                openHomePage();
              },
              boxcolor: Colors.white,
              textcolor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget selectprofilepic() {
    return Center(
      child: Stack(
        children: [
          _image != null
              ? CircleAvatar(
                  radius: 100,
                  backgroundImage: MemoryImage(_image!),
                )
              : const CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage(
                    'assets/defaultProfile.jpg',
                  ),
                ),
          Positioned(
            bottom: -6,
            left: 150,
            child: IconButton(
              onPressed: selectImage,
              icon: const Icon(
                Icons.add_a_photo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
