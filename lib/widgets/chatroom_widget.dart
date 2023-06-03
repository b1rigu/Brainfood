import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/chat_room_screen.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/widgets/active_status_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatRoomWidget extends StatefulWidget {
  final snap;
  const ChatRoomWidget({Key? key, required this.snap}) : super(key: key);

  @override
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  MyUser _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);
  MyUser senderInfo = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);
  var lastMessage;
  String lastText = 'Chat empty';
  String dateString = '';
  bool active = false;
  bool _isLoading = false;
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    String otherUid = widget.snap['peopleIds'][0];
    if (widget.snap['peopleIds'][0] == _user.uid) {
      otherUid = widget.snap['peopleIds'][1];
    }
    DocumentSnapshot userInfos =
        await fstore.collection('users').doc(otherUid).get();
    senderInfo = MyUser.fromSnap(userInfos);
    final DateTime lastActiveTime = senderInfo.lastActive.toDate();
    final DateTime timeNow = DateTime.now();
    final int difference = timeNow.difference(lastActiveTime).inMinutes;
    if (difference < 6) {
      active = true;
    } else {
      active = false;
    }
    QuerySnapshot sendermessages = await fstore
        .collection('chatrooms')
        .doc(widget.snap['docId'])
        .collection('messages')
        .orderBy('time', descending: true)
        .get();
    if (sendermessages.size == 0) {
      if (!mounted) return;
      setState(() {
        dataLoaded = true;
      });
      return;
    }
    lastMessage = sendermessages.docs[0].data();
    lastText = lastMessage['text'];
    if (lastMessage['time'] != null) {
      final Timestamp timestamp = lastMessage['time'] as Timestamp;
      final DateTime dateTime = timestamp.toDate();
      dateString = DateFormat('hh:mm a').format(dateTime);
    }
    if (!mounted) return;
    setState(() {
      dataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    double width = MediaQuery.of(context).size.width;
    getData();
    if (!dataLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 15,
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 15,
                          width: 140,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                    height: 15,
                    width: 60,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          openChatroom();
        },
        onLongPress: () {
          showOption();
        },
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          CachedNetworkImageProvider(senderInfo.photoUrl),
                    ),
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3.0),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: ActiveStatusWidget(active: active, radius: 12),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: width * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderInfo.username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        lastText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  dateString,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openChatroom() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          docId: widget.snap['docId'],
          senderInfo: senderInfo,
        ),
      ),
    );
    setState(() {
      dataLoaded = false;
    });
    getData();
  }

  void showOption() async {
    showModalBottomSheet(
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
              leading: const Icon(IconlyLight.delete),
              title: const Text('Delete chat from all'),
              onTap: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        title: const Text('Please Confirm'),
                        content: const Text(
                            'Are you sure you want to permanently delete this room?'),
                        actions: [
                          // The "Yes" button
                          TextButton(
                            onPressed: () async {
                              // Close the dialog
                              await FirestoreMethods()
                                  .deleteRoom(roomId: widget.snap['docId']);
                              if (!mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'No',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      );
                    });
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
