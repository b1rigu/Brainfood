import 'package:animations/animations.dart';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/edit_comment_screen.dart';
import 'package:brainfood/screens/message_search_screen.dart';
import 'package:brainfood/screens/profile_screen.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/search_widget.dart';
import 'package:brainfood/widgets/superellipse_shape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllCommentsScreen extends StatefulWidget {
  const AllCommentsScreen({Key? key}) : super(key: key);

  @override
  State<AllCommentsScreen> createState() => _AllCommentsScreenState();
}

class _AllCommentsScreenState extends State<AllCommentsScreen> {
  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'All comments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
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
                  return searchWidget(openContainer, 'Search comments...');
                },
                openBuilder: (_, __) {
                  return const MessageSearchScreen();
                },
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('bookcomments')
                .orderBy('postTime', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    bool isitcurrentusers = false;
                    if (user.uid == snapshot.data!.docs[index].data()['uid']) {
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
                                  snapshot.data!.docs[index].data(), context),
                              postBodyandHeader(
                                  snapshot.data!.docs[index].data(),
                                  context,
                                  isitcurrentusers),
                            ],
                          ),
                        ),
                      ),
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
}

Widget postBodyandHeader(snap, context, isitcurrentusers) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          postHeader(snap, context, isitcurrentusers),
          postText(snap),
        ],
      ),
    ),
  );
}

Widget postText(snap) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: ReadMoreText(
        snap['text'],
        trimLines: 6,
        colorClickableText: Colors.pink,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'See more',
        trimExpandedText: 'See less',
        moreStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple[300],
        ),
        lessStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple[300],
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget postHeader(snap, context, isitcurrentusers) {
  Timestamp posttime = snap['postTime'];
  DateTime postdate = posttime.toDate();
  String timeAgo = timeago.format(postdate, locale: 'en_short').toString();
  return Row(
    children: [
      Expanded(
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                openUserProfile(snap, context);
              },
              child: Text(
                snap['username'],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              ' • $timeAgo',
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      isitcurrentusers ? moreButton(context, snap) : const SizedBox.shrink(),
    ],
  );
}

Widget moreButton(context, snap) {
  return Padding(
    padding: const EdgeInsets.only(right: 12.0),
    child: GestureDetector(
      onTap: () {
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          ),
          context: context,
          builder: (context) {
            return ListView(
              primary: false,
              children: [
                ListTile(
                  leading: const Icon(IconlyLight.delete),
                  onTap: () async {
                    await deleteComment(context, snap);
                  },
                  title: const Text('Delete comment'),
                ),
                ListTile(
                  leading: const Icon(IconlyLight.edit),
                  onTap: () async {
                    await editComment(context, snap);
                  },
                  title: const Text('Edit comment'),
                ),
              ],
            );
          },
        );
      },
      child: const Icon(
        Icons.more_horiz,
        color: Colors.black54,
      ),
    ),
  );
}

void openUserProfile(snap, context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        userId: snap['uid'],
        userImageUrl: snap['userimageUrl'],
        username: snap['username'],
      ),
    ),
  );
}

Widget postProfilePic(snap, context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 12.0),
    child: GestureDetector(
      onTap: () {
        openUserProfile(snap, context);
      },
      child: ClipPath(
        clipper: CustomClipPath(),
        child: SizedBox(
          height: 40,
          width: 40,
          child: CachedNetworkImage(
            imageUrl: snap['userimageUrl'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}

Future deleteComment(context, snap) async {
  String res = await FirestoreMethods().deleteComment(snap['postId']);
  if (res == "success") {
    //success
    showSnackBar('Succesfully deleted', context, false);
  } else {
    showSnackBar(res, context, true);
  }
}

Future editComment(context, snap) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditCommentScreen(snap: snap),
    ),
  );
  showSnackBar('Succesfully saved changes', context, false);
}
