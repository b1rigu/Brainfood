import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/widgets/chatroom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({Key? key}) : super(key: key);

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  List<MyUser> chatroomPeople = [];
  List<dynamic> chatrooms = [];
  List<dynamic> chatroomSearchResults = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void getData() async {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    chatroomPeople.clear();
    QuerySnapshot<Map<String, dynamic>> allChatRooms = await fstore
        .collection('chatrooms')
        .where('peopleIds', arrayContains: user.uid)
        .orderBy('lastChat', descending: true)
        .get();
    for (var chatroom in allChatRooms.docs) {
      var myRoom = chatroom.data();
      String otherUid = myRoom['peopleIds'][0];
      if (myRoom['peopleIds'][0] == user.uid) {
        otherUid = myRoom['peopleIds'][1];
      }
      DocumentSnapshot userInfos =
          await fstore.collection('users').doc(otherUid).get();
      MyUser senderInfo = MyUser.fromSnap(userInfos);
      chatroomPeople.add(senderInfo);
      chatrooms.add(myRoom);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                      return ChatRoomWidget(snap: chatroomSearchResults[index]);
                    },
                    itemCount: chatroomSearchResults.length,
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
    chatroomSearchResults.clear();
    setState(() => _isLoading = true);
    if (value == '') {
      //empty
    } else {
      for (int i = 0; i < chatroomPeople.length; i++) {
        if (chatroomPeople[i]
            .username
            .toLowerCase()
            .contains(value.toLowerCase())) {
          chatroomSearchResults.add(chatrooms[i]);
        }
      }
    }
    setState(() => _isLoading = false);
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
          hintText: 'Search messages...',
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
