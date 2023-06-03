import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/edit_profile_screen.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/widgets/post_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final userImageUrl;
  final username;
  final userId;
  const ProfileScreen({
    Key? key,
    required this.userId,
    this.userImageUrl,
    this.username,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DraggableScrollableController draggableScrollableControllerPosts =
      DraggableScrollableController();
  bool isUser = false;
  bool closeTopBook = false;
  bool logout = false;
  List<Widget> buttons = [];

  @override
  void initState() {
    super.initState();
    checkUser();
    addWidget();
    draggableScrollableControllerPosts.addListener(() {
      setState(() {
        closeTopBook = draggableScrollableControllerPosts.size >= 0.9;
      });
    });
  }

  void checkUser() {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    if (user.uid == widget.userId) {
      setState(() {
        isUser = true;
      });
    }
  }

  void addWidget() {
    buttons.addAll([
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 128.0),
        child: Divider(
          thickness: 3.0,
          color: Colors.black54,
        ),
      ),
      buttonWidget(() {}, IconlyLight.setting, 'Settings'),
      buttonWidget(() {}, IconlyLight.heart, 'Liked'),
      buttonWidget(() {
        logOut();
      }, IconlyLight.logout, 'Logout'),
    ]);
  }

  void logOut() async {
    setState(() {
      logout = true;
    });
    await FirebaseAuthMethods().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/secondroute', (Route<dynamic> route) => false);
  }

  Widget buttonWidget(
    Function() ontap,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: ontap,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).getUser;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                headerWidget(user),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(150)),
                        border: Border.all(
                            color: const Color.fromRGBO(149, 117, 205, 1)),
                      ),
                    ),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: CachedNetworkImageProvider(
                        isUser ? user.photoUrl : widget.userImageUrl,
                      ),
                    ),
                    isUser
                        ? Positioned(
                            bottom: -5,
                            right: -12,
                            child: IconButton(
                              onPressed: () {
                                openEditScreen();
                              },
                              icon: const Icon(
                                IconlyLight.edit,
                                size: 32.0,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: [
                    //username and email text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? user.username : widget.username,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        isUser
                            ? Text(
                                user.email,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    //more button
                    isUser ? moreWidget() : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            DraggableScrollableSheet(
              minChildSize: 0.5,
              initialChildSize: 0.5,
              maxChildSize: 0.9,
              controller: draggableScrollableControllerPosts,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 224, 224, 224),
                        Color.fromARGB(255, 255, 255, 255),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 16.0, left: 24.0, bottom: 16.0),
                        child: SizedBox(
                          height: 30,
                          child: Text(
                            'Posts',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 28,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      logout
                          ? const SizedBox.shrink()
                          : StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .where('uid',
                                      isEqualTo:
                                          isUser ? user.uid : widget.userId)
                                  .orderBy('postTime', descending: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                return Expanded(
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: snapshot.data != null
                                        ? snapshot.data!.docs.length
                                        : 0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return PostContainer(
                                        snap: snapshot.data!.docs[index].data(),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget moreWidget() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          context: context,
          builder: (context) {
            return ListView.builder(
              primary: false,
              itemBuilder: (context, index) {
                return buttons[index];
              },
              itemCount: buttons.length,
            );
          },
        );
      },
      child: CachedNetworkImage(
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/151/151917.png',
        width: 25,
        height: 25,
      ),
    );
  }

  Widget headerWidget(user) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: closeTopBook
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          IconButton(
            splashRadius: 16,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 8.0),
          closeTopBook ? const Spacer() : const SizedBox.shrink(),
          closeTopBook
              ? isUser
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          CachedNetworkImageProvider(widget.userImageUrl),
                    )
              : const SizedBox.shrink(),
          closeTopBook ? const Spacer() : const SizedBox.shrink(),
          closeTopBook
              ? isUser
                  ? Padding(
                      padding: const EdgeInsets.all(16.0), child: moreWidget())
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),
          closeTopBook
              ? const SizedBox.shrink()
              : isUser
                  ? const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
        ],
      ),
    );
  }

  void openEditScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
      ),
    );
    setState(() {});
  }
}
