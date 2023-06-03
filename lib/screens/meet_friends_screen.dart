import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/bouncing_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';

class MeetFriendsScreen extends StatefulWidget {
  const MeetFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MeetFriendsScreen> createState() => _MeetFriendsScreenState();
}

class _MeetFriendsScreenState extends State<MeetFriendsScreen> {
  late final SwipableStackController _controller;
  double height = 0.0;
  List<dynamic> suggestingUsers = [];

  void _listenController() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController()..addListener(_listenController);
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  void swipeRight() {
    _controller.next(
      swipeDirection: SwipeDirection.right,
    );
  }

  void swipeLeft() {
    _controller.next(
      swipeDirection: SwipeDirection.left,
    );
  }

  void getData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
    if (!mounted) return;
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    suggestingUsers.clear();
    QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .get();
    for (var localuser in users.docs) {
      suggestingUsers.add(localuser.data());
    }
    for (var friendUid in user.friends) {
      suggestingUsers.removeWhere((element) => element['uid'] == friendUid);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBar(context, false),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.7,
            child: swipeableWidget(user),
          ),
        ],
      ),
    );
  }

  Widget buttonWidget(Color boxcolor, Color iconcolor, IconData icon) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: boxcolor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: iconcolor,
        ),
      ),
    );
  }

  Widget swipeableWidget(MyUser user) {
    return SwipableStack(
      allowVerticalSwipe: false,
      detectableSwipeDirections: const {
        SwipeDirection.right,
        SwipeDirection.left,
      },
      dragStartBehavior: DragStartBehavior.down,
      controller: _controller,
      onSwipeCompleted: (index, direction) {
        print('$index, $direction');
      },
      itemCount: suggestingUsers.length,
      builder: (context, properties) {
        return friendWidget(suggestingUsers[properties.index]);
      },
    );
  }

  Widget friendWidget(snap) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: height * 0.54,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  pictureWidget(snap),
                  bottomBlueWidget(),
                  nameBioandAgeWidget(snap),
                  majorWidget(),
                ],
              ),
            ),
            dismissandLoveButton(),
          ],
        ),
      ),
    );
  }

  Widget dismissandLoveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Bouncing(
            onPress: () {
              swipeLeft();
            },
            child: buttonWidget(
              const Color.fromRGBO(149, 117, 205, 0.3),
              const Color.fromRGBO(149, 117, 205, 1),
              FontAwesomeIcons.xmark,
            ),
          ),
          Bouncing(
            onPress: () {
              swipeRight();
            },
            child: buttonWidget(
              const Color.fromRGBO(149, 117, 205, 1),
              Colors.white,
              FontAwesomeIcons.heartCircleBolt,
            ),
          ),
        ],
      ),
    );
  }

  Widget pictureWidget(snap) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: snap['photoUrl'],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget bottomBlueWidget() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.7),
              Color.fromRGBO(0, 0, 0, 0),
              Color.fromRGBO(0, 0, 0, 0),
              Color.fromRGBO(0, 0, 0, 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget nameBioandAgeWidget(snap) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                snap['username'],
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                ', 18',
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Small bio, to introduce',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget majorWidget() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 34,
            width: double.infinity,
            child: FittedBox(
              alignment: Alignment.centerRight,
              child: Container(
                height: 34,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(24),
                  ),
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Computer science',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
