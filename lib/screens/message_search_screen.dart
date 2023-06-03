import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/see_all_comments_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class MessageSearchScreen extends StatefulWidget {
  const MessageSearchScreen({Key? key}) : super(key: key);

  @override
  State<MessageSearchScreen> createState() => _MessageSearchScreenState();
}

class _MessageSearchScreenState extends State<MessageSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> comments = [];
  List<dynamic> commentSearchResults = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> allcomments = await fstore
        .collection('bookcomments')
        .orderBy('postId', descending: true)
        .get();
    for (var comment in allcomments.docs) {
      var myComment = comment.data();
      comments.add(myComment);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    itemBuilder: (context, index) {
                      bool isitcurrentusers = false;
                      if (user.uid == commentSearchResults[index]['uid']) {
                        isitcurrentusers = true;
                      } else {
                        isitcurrentusers = false;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                postProfilePic(
                                    commentSearchResults[index], context),
                                postBodyandHeader(commentSearchResults[index],
                                    context, isitcurrentusers),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: commentSearchResults.length,
                  ),
                ),
              ],
            ),
            searchWidget(),
          ],
        ),
      ),
    );
  }

  void updateList(String value) async {
    commentSearchResults.clear();
    if (value == '') {
      //empty
    } else {
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['text'].toLowerCase().contains(value.toLowerCase())) {
          commentSearchResults.add(comments[i]);
        }
      }
    }
    setState(() {});
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          updateList(value);
        },
        autofocus: true,
        textAlignVertical: TextAlignVertical.top,
        controller: _searchController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            IconlyLight.search,
            color: Colors.black87,
            size: 28,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search comments...',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.of(context).pop();
              } else {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                updateList('');
              }
            },
            icon: const Icon(
              Icons.close,
              color: Color.fromRGBO(149, 117, 205, 1),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
