import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/edit_post_screen.dart';
import 'package:brainfood/screens/profile_screen.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/carousel.dart';
import 'package:brainfood/widgets/imageViewWidget.dart';
import 'package:brainfood/widgets/superellipse_shape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostContainer extends StatefulWidget {
  final snap;
  const PostContainer({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  String timeAgo = '';
  bool isitcurrentusers = false;
  bool ispostliked = false;
  MyUser _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);
  bool _isLoading = false;
  int _current = 0;

  void gettimeago() {
    Timestamp posttime = widget.snap['postTime'];
    DateTime postdate = posttime.toDate();
    timeAgo = timeago.format(postdate, locale: 'en_short').toString();
  }

  void ispostcurrentUsers() {
    if (_user.uid == widget.snap['uid']) {
      if (!mounted) return;
      setState(() {
        isitcurrentusers = true;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isitcurrentusers = false;
      });
    }
  }

  void isliked() {
    bool islikedlocal =
        FirestoreMethods().isliked(widget.snap['likedpeople'], _user);
    if (!mounted) return;
    setState(() {
      ispostliked = islikedlocal;
    });
  }

  void addlikes() async {
    await FirestoreMethods().addlikes(widget.snap['postId'], _user);
  }

  void removelikes() async {
    await FirestoreMethods().removelikes(widget.snap['postId'], _user);
  }

  Future deletePost() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    String res = await FirestoreMethods()
        .deletePost(widget.snap['postId'], widget.snap['imageUrl'].length);
    if (res == "success") {
      //success
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBar('Succesfully deleted', context, false);
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBar(res, context, true);
    }
  }

  Future editPost() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPostScreen(snap: widget.snap),
      ),
    );
    if (!mounted) return;
    showSnackBar('Succesfully saved changes', context, true);
  }

  openDetailedPost() {}

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    gettimeago();
    ispostcurrentUsers();
    isliked();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        postProfilePic(),
        postBodyandHeader(),
      ],
    );
  }

  Widget postBodyandHeader() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            postHeader(),
            postText(),
            postPictures(),
            likeWidget(),
          ],
        ),
      ),
    );
  }

  Widget postPictures() {
    if (widget.snap['imageUrl'].isEmpty) {
      return const SizedBox.shrink();
    } else if (widget.snap['imageUrl'].length == 1) {
      return LayoutBuilder(builder: (context, constraints) {
        return ImageViewWidget(
          imageUrl: widget.snap['imageUrl'][0],
          aspectRatio: widget.snap['aspectRatio'],
          width: constraints.maxWidth,
        );
      });
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CustomCarousel(
            images: widget.snap['imageUrl'],
            aspectRatio: widget.snap['aspectRatio'],
            width: constraints.maxWidth,
          ),
        ],
      );
    });
  }

  Widget postProfilePic() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 12.0),
      child: GestureDetector(
        onTap: () {
          openUserProfile();
        },
        child: ClipPath(
          clipper: CustomClipPath(),
          child: SizedBox(
            height: 40,
            width: 40,
            child: CachedNetworkImage(
              imageUrl: widget.snap['userimageUrl'],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget postText() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ReadMoreText(
          widget.snap['caption'],
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

  Widget postHeader() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  openUserProfile();
                },
                child: Text(
                  widget.snap['username'],
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
        isitcurrentusers ? moreButton() : const SizedBox.shrink(),
      ],
    );
  }

  Widget moreButton() {
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
                      await deletePost();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    title: const Text('Delete post'),
                  ),
                  ListTile(
                    leading: const Icon(IconlyLight.edit),
                    onTap: () async {
                      await editPost();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    title: const Text('Edit post'),
                  ),
                  ListTile(
                    leading: const Icon(IconlyLight.send),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    title: const Text('Share post'),
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

  Widget likeWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          LikeButton(
            onTap: (isLiked) async {
              if (ispostliked) {
                removelikes();
              } else {
                addlikes();
              }
              return !isLiked;
            },
            size: 22,
            isLiked: ispostliked,
            likeCount: widget.snap['likes'],
            likeCountPadding: const EdgeInsets.symmetric(horizontal: 12),
            likeBuilder: (istapped) {
              return FaIcon(
                FontAwesomeIcons.circleUp,
                color: istapped ? Colors.deepPurple[300] : Colors.grey,
                size: 24,
              );
            },
          ),
        ],
      ),
    );
  }

  void openUserProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: widget.snap['uid'],
          userImageUrl: widget.snap['userimageUrl'],
          username: widget.snap['username'],
        ),
      ),
    );
  }
}
