import 'package:animations/animations.dart';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/add_book_screen.dart';
import 'package:brainfood/screens/add_message_screen.dart';
import 'package:brainfood/screens/book_detail_screen.dart';
import 'package:brainfood/screens/book_search_screen.dart';
import 'package:brainfood/screens/profile_screen.dart';
import 'package:brainfood/screens/see_all_comments_screen.dart';
import 'package:brainfood/screens/wish_list_books_screen.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/book_container.dart';
import 'package:brainfood/widgets/dummy_book_widget.dart';
import 'package:brainfood/widgets/search_widget.dart';
import 'package:brainfood/widgets/superellipse_shape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  List<dynamic> bookSearchResults = [];
  List<dynamic> tempbookSearchResults = [];
  bool _isLoading = false;
  List<String> bookGenres = [
    'Clear',
    'БАЙГАЛИЙН ШИНЖЛЭЛ',
    'БИЗНЕС, ЭДИЙН ЗАСАГ',
    'БЭЛГИЙН НОМ',
    'ГАЗРЫН ЗУРАГ',
    'КОМИК, МАНГА',
    'МАТЕМАТИК, ШИНЖЛЭХ УХААН',
    'НАМТАР, ДУРСАМЖ',
    'НАРИЙН МЭРГЭЖИЛ, ҮЙЛДВЭРЛЭЛ',
    'НИЙГМИЙН ШИНЖЛЭХ УХААН',
    'НЭВТЭРХИЙ ТОЛЬ, ГАРЫН АВЛАГА',
    'ӨӨРТӨӨ ТУСЛАХ',
    'СПОРТ',
    'СУРАХ БИЧИГ',
    'ТҮҮХ',
    'УРАН ЗОХИОЛ',
    'УРЛАГ, СОЁЛ, ГЭРЭЛ ЗУРАГ',
    'ХОББИ, ЧӨЛӨӨТ ЦАГ, ХООЛ',
    'ХӨДӨӨ АЖ АХУЙ',
    'ХУУЛЬ, ЭРХ ЗҮЙ',
    'ХҮҮХДИЙН НОМ',
    'ХЭЛ, ТОЛЬ БИЧИГ',
    'ШАШИН',
    'ЭРҮҮЛ МЭНД, ГЭР БҮЛ',
    'БУСАД',
  ];
  String chosenGenre = 'Clear';

  void updateList() {
    bookSearchResults.clear();
    if (chosenGenre.isNotEmpty && chosenGenre != 'Clear') {
      for (var result in tempbookSearchResults) {
        if (result['genre'] == chosenGenre) {
          bookSearchResults.add(result);
        }
      }
    } else {
      bookSearchResults.addAll(tempbookSearchResults);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, true),
      body: Stack(
        children: [
          Column(
            children: [
              headWidget(),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    bookComments(),
                    booksWidget(),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OpenContainer(
                onClosed: (data) {
                  updateList();
                },
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
                  return const AddBookScreen();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 100),
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
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 25,
                      ),
                    ),
                  );
                },
                openBuilder: (_, __) {
                  return const AddMessageScreen();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget booksWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('books')
          .orderBy('postTime', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildListDelegate(
              [
                dummyBookWidget(),
                dummyBookWidget(),
                dummyBookWidget(),
                dummyBookWidget(),
              ],
            ),
          );
        }
        tempbookSearchResults.clear();
        for (var item in snapshot.data!.docs) {
          tempbookSearchResults.add(item.data());
        }
        updateList();
        if (bookSearchResults.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No result found',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: OpenContainer(
                  closedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  closedElevation: 1,
                  transitionType: ContainerTransitionType.fadeThrough,
                  closedBuilder: (_, openContainer) {
                    return BookContainer(
                      ontap: openContainer,
                      snap: bookSearchResults[index],
                    );
                  },
                  openBuilder: (_, __) {
                    return BookDetailScreen(
                      snap: bookSearchResults[index],
                    );
                  },
                ),
              );
            },
            childCount: bookSearchResults.length,
          ),
        );
      },
    );
  }

  void openWishlist() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WishListBooksScreen(),
      ),
    );
  }

  Widget headWidget() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, bottom: 16.0, left: 16.0, right: 8.0),
              child: OpenContainer(
                closedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                transitionType: ContainerTransitionType.fadeThrough,
                closedBuilder: (_, openContainer) {
                  return searchWidget(openContainer, 'Search books...');
                },
                openBuilder: (_, __) {
                  return const BookSearchScreen();
                },
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                openWishlist();
              },
              child: const SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  IconlyLight.heart,
                  size: 28,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        primary: false,
                        itemBuilder: (context, index) {
                          if (chosenGenre == bookGenres[index]) {
                            return ListTile(
                              dense: true,
                              selected: true,
                              selectedColor: Colors.white,
                              selectedTileColor: Colors.deepPurple[300],
                              leading: const Icon(IconlyLight.bookmark),
                              onTap: () {
                                setState(() {
                                  chosenGenre = bookGenres[index];
                                });
                                updateList();
                                Navigator.of(context).pop();
                              },
                              title: Text(bookGenres[index]),
                            );
                          }
                          return ListTile(
                            dense: true,
                            leading: const Icon(IconlyLight.bookmark),
                            onTap: () {
                              setState(() {
                                chosenGenre = bookGenres[index];
                              });
                              updateList();
                              Navigator.of(context).pop();
                            },
                            title: Text(bookGenres[index]),
                          );
                        },
                        itemCount: bookGenres.length,
                      ),
                    );
                  },
                );
              },
              child: const SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  IconlyLight.filter,
                  size: 28,
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 8.0)),
        ],
      ),
    );
  }

  Widget bookComments() {
    MyUser user = Provider.of<UserProvider>(context).getUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('bookcomments')
          .orderBy('postTime', descending: true)
          .limit(2)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildListDelegate(
              [
                dummyCommentWidget(),
              ],
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == snapshot.data!.docs.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      openAllComments();
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200]),
                      child: const Center(child: Text('Tap to see more')),
                    ),
                  ),
                );
              }
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
                          isitcurrentusers,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: snapshot.data!.docs.isNotEmpty
                ? snapshot.data!.docs.length + 1
                : 0,
          ),
        );
      },
    );
  }

  void openUserProfile(snap) {
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

  Widget dummyCommentWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 20,
      ),
    );
  }

  void openAllComments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllCommentsScreen(),
      ),
    );
  }
}
