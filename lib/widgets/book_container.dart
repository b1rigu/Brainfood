import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

class BookContainer extends StatefulWidget {
  final Function() ontap;
  final snap;
  const BookContainer({Key? key, required this.ontap, required this.snap})
      : super(key: key);

  @override
  State<BookContainer> createState() => _BookContainerState();
}

class _BookContainerState extends State<BookContainer> {
  bool isbookwishlisted = false;
  MyUser _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);

  void isWishListed() {
    bool islikedlocal =
        FirestoreMethods().isWishlisted(widget.snap['wishListedUids'], _user);
    if (!mounted) return;
    setState(() {
      isbookwishlisted = islikedlocal;
    });
  }

  void addtoWishList() async {
    await FirestoreMethods().addtoWishList(widget.snap['postId'], _user);
  }

  void removefromWishList() async {
    await FirestoreMethods().removefromWishList(widget.snap['postId'], _user);
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    isWishListed();
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                height: 110,
                child: bookPic(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: bookInfo()),
                          LikeButton(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            onTap: (isLiked) async {
                              if (isbookwishlisted) {
                                removefromWishList();
                              } else {
                                addtoWishList();
                              }
                              return !isLiked;
                            },
                            size: 32,
                            isLiked: isbookwishlisted,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //book price
                        SizedBox(
                          width: 200,
                          child: Text(
                            '${widget.snap['price']} ₮',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookPic() {
    if (widget.snap['imageUrl'].isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.snap['imageUrl'][0],
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.deepPurple[300],
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(149, 117, 205, 1),
            Color.fromRGBO(117, 149, 205, 1),
            Color.fromRGBO(66, 158, 245, 1),
          ],
        ),
      ),
      child: const Center(child: Text('No Image')),
    );
  }

  Widget bookInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //book name
          Text(
            widget.snap['bookname'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // //author
          // Text(
          //   widget.snap['author'],
          //   style: const TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.w300,
          //   ),
          // ),
          // const SizedBox(height: 5),
          //genre
          SizedBox(
            width: 140,
            child: Text(
              widget.snap['genre'],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 5),
          //seller
          Text(
            'by ${widget.snap['username']}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
