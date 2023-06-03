import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:brainfood/screens/add_post_screen.dart';
import 'package:brainfood/screens/meet_friends_nav_screen.dart';
import 'package:brainfood/screens/post_people_search_screen.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/post_container.dart';
import 'package:brainfood/widgets/search_widget.dart';
import 'package:brainfood/widgets/stories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  bool hideTopSearch = false;
  int _touchCount = 0;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        hideTopSearch = scrollController.offset > 10;
      });
    });
  }

  void openAddPostScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPostScreen(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  void openFriendsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MeetFriendsNavScreen(isMessage: false),
      ),
    );
  }

  void _incrementEnter(PointerEvent details) {
    setState(() {
      _touchCount++;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      _touchCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, true),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Listener(
            onPointerDown: _incrementEnter,
            onPointerUp: _incrementExit,
            onPointerCancel: _incrementExit,
            child: CustomScrollView(
              physics: _touchCount > 1
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedContainer(
                    height: hideTopSearch ? 0 : 90,
                    duration: const Duration(milliseconds: 200),
                  ),
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      openFriendsScreen();
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return const Stories();
                            },
                          ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(149, 117, 205, 0),
                                    Color.fromRGBO(149, 117, 205, 0.4),
                                  ],
                                ),
                                border: Border.symmetric(
                                    horizontal: BorderSide(
                                        color:
                                            Color.fromRGBO(149, 117, 205, 0.3),
                                        width: 2)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tap here to find people with same interest',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('postTime', descending: true)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return PostContainer(
                            snap: snapshot.data!.docs[index].data(),
                          );
                        },
                        childCount: snapshot.data != null
                            ? snapshot.data!.docs.length
                            : 0,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          //search widget
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OpenContainer(
                closedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                transitionType: ContainerTransitionType.fadeThrough,
                closedBuilder: (_, openContainer) {
                  return searchWidget(
                      openContainer, 'Search posts and people...');
                },
                openBuilder: (_, __) {
                  return const PostPeopleSearchScreen();
                },
              ),
            ),
          ),
          //add post button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OpenContainer(
              closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(60.0))),
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (_, openContainer) {
                return GestureDetector(
                  onTap: openContainer,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(149, 117, 205, 1),
                          Color.fromRGBO(66, 158, 245, 1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 25,
                    ),
                  ),
                );
              },
              openBuilder: (_, __) {
                return const AddPostScreen();
              },
            ),
          ),
        ],
      ),
    );
  }
}
