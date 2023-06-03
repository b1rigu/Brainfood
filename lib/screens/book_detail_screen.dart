import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/bouncing_button.dart';
import 'package:brainfood/widgets/fullscreen_slider_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

class BookDetailScreen extends StatefulWidget {
  final snap;
  const BookDetailScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  ScrollController controller = ScrollController();
  bool closeTopBook = false;
  bool alreadyScrolled = false;
  bool reachBottom = false;
  double height = 0.0;
  int _current = 0;
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
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        closeTopBook = controller.offset > 40;
      });
      if (controller.offset + 20 >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        reachBottom = true;
      } else if (alreadyScrolled &&
          controller.offset < controller.position.maxScrollExtent &&
          reachBottom) {
        double start = controller.position.minScrollExtent;
        controller.animateTo(start,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn);
      }
      if (controller.offset <= controller.position.minScrollExtent &&
          !controller.position.outOfRange) {
        alreadyScrolled = false;
        reachBottom = false;
      }
      if (closeTopBook && !alreadyScrolled && !reachBottom) {
        double end = controller.position.maxScrollExtent;
        controller.animateTo(end,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn);
        alreadyScrolled = true;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isWishListed();
      checkPic();
    });
  }

  void checkPic() {
    if (widget.snap['imageUrl'].isEmpty) {
      double end = controller.position.maxScrollExtent;
      controller.animateTo(end,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);
      alreadyScrolled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBar(context, true),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bookPictureWidget(),
                    bookNameandGenre(),
                    dividerWidget(),
                    publishedbyWidget(),
                    bookDescriptionWidget(),
                  ],
                ),
              ),
            ),
            closeTopBook ? const SizedBox.shrink() : bottomWhiteBlurWidget(),
            contactOwnerBTN(),
          ],
        ),
      ),
    );
  }

  Widget bookPictureWidget() {
    return SizedBox(
      height: 340,
      child: Stack(
        alignment: closeTopBook ? Alignment.bottomCenter : Alignment.center,
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color.fromRGBO(66, 158, 245, 1),
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromRGBO(149, 117, 205, 1),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.0)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedContainer(
                  height: closeTopBook ? 120 : 250,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: CarouselSlider.builder(
                    itemCount: widget.snap['imageUrl'].length,
                    itemBuilder: (context, index, realIndex) {
                      final urlImage = widget.snap['imageUrl'][index];
                      return imageViewWidget(urlImage);
                    },
                    options: CarouselOptions(
                        enableInfiniteScroll: false,
                        height: closeTopBook ? 120 : 250,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        disableCenter: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }),
                  ),
                  // child: const CustomCarousel(
                  //   images: _images,
                  //   aspectRatio: 1.3,
                  // ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.snap['imageUrl']
                    .asMap()
                    .entries
                    .map<Widget>((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  );
                }).toList(),
              ),
              SizedBox(height: closeTopBook ? 0 : 40),
            ],
          ),
          AnimatedAlign(
            alignment:
                closeTopBook ? Alignment.bottomLeft : Alignment.bottomCenter,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 35,
                width: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 185, 151, 1),
                      Color.fromRGBO(246, 126, 125, 1),
                    ],
                  ),
                ),
                child: bookPrice(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageViewWidget(String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          openFullscreenView();
        },
        child: CachedNetworkImage(imageUrl: image, fit: BoxFit.contain),
      ),
    );
  }

  Widget contactOwnerBTN() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Bouncing(
          onPress: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                    title: Text(
                      'Phone Number: ${widget.snap['userphonenumber']}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                });
          },
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromRGBO(247, 86, 114, 1),
                ],
              ),
            ),
            child: const Text(
              'CONTACT THE OWNER',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomWhiteBlurWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 150,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(255, 255, 255, 1),
              Color.fromRGBO(255, 255, 255, 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookNameandGenre() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Text(
                  widget.snap['bookname'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  widget.snap['genre'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(252, 161, 125, 1),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Books to trade:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),

              // booksToTrade
              ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '- ${widget.snap['booksToTrade'][index]}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                itemCount: widget.snap['booksToTrade'].length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
        //like Button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: LikeButton(
            crossAxisAlignment: CrossAxisAlignment.start,
            onTap: (isLiked) async {
              if (isLiked) {
                removefromWishList();
              } else {
                addtoWishList();
              }
              return !isLiked;
            },
            size: 40,
            isLiked: isbookwishlisted,
          ),
        ),
      ],
    );
  }

  Widget dividerWidget() {
    return const Padding(
      padding: EdgeInsets.only(right: 12.0, left: 12.0),
      child: Divider(
        thickness: 0.5,
        color: Color.fromRGBO(149, 117, 205, 1),
      ),
    );
  }

  Widget bookDescriptionWidget() {
    return SizedBox(
      height: height * 0.52,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: Text(
          widget.snap['bookcaption'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget bookPrice() {
    return Center(
      child: Text(
        '${widget.snap['price']} ₮',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget publishedbyWidget() {
    return Row(
      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0, right: 3.0),
          child: Text(
            'Published by',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          widget.snap['username'],
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(252, 161, 125, 1),
          ),
        ),
      ],
    );
  }

  void openFullscreenView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullscreenSlider(snap: widget.snap, isChat: false, index: 0),
      ),
    );
  }
}
