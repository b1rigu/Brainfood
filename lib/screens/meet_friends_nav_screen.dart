import 'package:brainfood/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MeetFriendsNavScreen extends StatefulWidget {
  final bool isMessage;
  const MeetFriendsNavScreen({Key? key, required this.isMessage})
      : super(key: key);

  @override
  State<MeetFriendsNavScreen> createState() => _MeetFriendsNavScreenState();
}

class _MeetFriendsNavScreenState extends State<MeetFriendsNavScreen> {
  var _currentIndex = 0;

  navigationTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.isMessage ? 2 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: meetFriendsItems[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        currentIndex: _currentIndex,
        onTap: navigationTapped,
        items: [
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.heartCircleBolt),
            title: const Text("Suggestion"),
            selectedColor: Colors.deepPurple[300],
          ),
          SalomonBottomBarItem(
            icon: const Icon(IconlyBold.star, size: 28),
            title: const Text("Stars"),
            selectedColor: Colors.deepPurple[300],
          ),
          SalomonBottomBarItem(
            icon: const Icon(
              IconlyBold.message,
              size: 28,
            ),
            title: const Text("Chat"),
            selectedColor: Colors.deepPurple[300],
          ),
        ],
      ),
    );
  }
}
