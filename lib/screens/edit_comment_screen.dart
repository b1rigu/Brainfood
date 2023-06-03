import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditCommentScreen extends StatefulWidget {
  final snap;
  const EditCommentScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<EditCommentScreen> createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.snap['text'];
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Edit comment',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: height * 0.1),
          postFieldWidget(),
          MyTextButton(
            text: 'Save changes',
            onPressed: () {
              saveComment();
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

  Widget postFieldWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        textAlignVertical: TextAlignVertical.top,
        controller: _editController,
        keyboardType: TextInputType.multiline,
        minLines: 6,
        maxLines: 12,
        maxLength: 2000,
        maxLengthEnforcement: MaxLengthEnforcement.none,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Edit your post',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              _editController.clear();
              FocusScope.of(context).unfocus();
            },
            icon: const Icon(
              Icons.close,
              color: Color.fromRGBO(149, 117, 205, 1),
            ),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  void saveComment() async {
    await FirestoreMethods()
        .saveComment(widget.snap['postId'], _editController.text.trim());
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
