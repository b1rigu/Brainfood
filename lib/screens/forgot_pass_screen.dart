import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';

class ForgotPassScreen extends StatefulWidget {
  final String email;
  const ForgotPassScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  void resetPassword() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods()
        .sendPassResetLink(email: _emailController.text.trim());
    if (res == "success") {
      //success
      if (!mounted) return;
      showSnackBar('Sent the link, Check your email(Inbox, Spam folders)',
          context, false);
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          const Center(
            child: Text(
              'Forgot password!',
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Text(
              'Enter your Email and we will send you a password reset link',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
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
          SizedBox(
            height: height * 0.03,
          ),
          MyTextButton(
            text: 'Reset Password',
            onPressed: () {
              resetPassword();
            },
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(149, 117, 205, 1),
                Color.fromRGBO(247, 86, 114, 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
