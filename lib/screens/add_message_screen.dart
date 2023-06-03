import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMessageScreen extends StatefulWidget {
  const AddMessageScreen({Key? key}) : super(key: key);

  @override
  State<AddMessageScreen> createState() => _AddMessageScreenState();
}

class _AddMessageScreenState extends State<AddMessageScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'New message',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.07,
          ),
          MyTextField(
            keyboardType: TextInputType.text,
            labelText: 'Comment',
            controller: _textController,
            useFormatter: false,
            onpressX: () {
              _textController.clear();
            },
          ),
          SizedBox(
            height: height * 0.05,
          ),
          MyTextButton(
            text: 'Publish',
            onPressed: () {
              publishComment();
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

  void publishComment() async {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    if (_textController.text.isNotEmpty) {
      await FirestoreMethods().uploadComment(
        username: user.username,
        uid: user.uid,
        userimageUrl: user.photoUrl,
        text: _textController.text.trim(),
      );
    } else {
      showSnackBar('comment cannot be empty', context, true);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
