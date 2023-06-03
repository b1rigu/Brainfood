import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/meet_friends_nav_screen.dart';
import 'package:brainfood/screens/profile_screen.dart';
import 'package:brainfood/widgets/icon_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'superellipse_shape.dart';

PreferredSizeWidget appBar(BuildContext context, bool friendsEnabled) {
  void openFriendsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MeetFriendsNavScreen(isMessage: true),
      ),
    );
  }

  void openProfileScreen(String uid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: uid),
      ),
    );
  }

  MyUser user = Provider.of<UserProvider>(context, listen: true).getUser;

  return AppBar(
    elevation: 0,
    title: const Text(
      'brainfood',
      style: TextStyle(
        fontFamily: 'Righteous',
        fontSize: 24,
        color: Color.fromRGBO(149, 117, 205, 1),
      ),
    ),
    actions: [
      friendsEnabled
          ? IconnButton(
              icon: IconlyLight.message,
              iconSize: 22,
              onPressed: () {
                openFriendsScreen();
              },
              right: 15,
            )
          : const SizedBox.shrink(),
      GestureDetector(
        onTap: () {
          openProfileScreen(user.uid);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 25.0, top: 15.0, bottom: 15.0),
          child: ClipPath(
            clipper: CustomClipPath(),
            child: SizedBox(
              width: 25,
              child: CachedNetworkImage(
                imageUrl: user.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
