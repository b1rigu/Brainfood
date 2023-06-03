import 'package:animations/animations.dart';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/chat_people_add_screen.dart';
import 'package:brainfood/screens/chat_search_screen.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/chatroom_widget.dart';
import 'package:brainfood/widgets/search_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class MeetFriendsChat extends StatefulWidget {
  const MeetFriendsChat({Key? key}) : super(key: key);

  @override
  State<MeetFriendsChat> createState() => _MeetFriendsChatState();
}

class _MeetFriendsChatState extends State<MeetFriendsChat> {
  MyUser _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;

    return Scaffold(
      appBar: appBar(context, false),
      body: Column(
        children: [
          headerWidget(),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('peopleIds', arrayContains: _user.uid)
                .orderBy('lastChat', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatRoomWidget(
                      snap: snapshot.data!.docs[index].data(),
                    );
                  },
                  itemCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget headerWidget() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: OpenContainer(
              closedElevation: 0.0,
              closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (_, openContainer) {
                return searchWidget(openContainer, 'Search messages');
              },
              openBuilder: (_, __) {
                return const ChatSearchScreen();
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
            child: GestureDetector(
              onTap: () {
                openPeopleList();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 50,
                width: 50,
                child: const Center(
                  child: Icon(
                    IconlyLight.add_user,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void openPeopleList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChatPeople(),
      ),
    );
  }
}
