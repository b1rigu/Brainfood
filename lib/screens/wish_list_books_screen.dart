import 'package:animations/animations.dart';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/book_detail_screen.dart';
import 'package:brainfood/widgets/book_container.dart';
import 'package:brainfood/widgets/dummy_book_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishListBooksScreen extends StatefulWidget {
  const WishListBooksScreen({Key? key}) : super(key: key);

  @override
  State<WishListBooksScreen> createState() => _WishListBooksScreenState();
}

class _WishListBooksScreenState extends State<WishListBooksScreen> {
  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Wishlisted books',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('books')
                .where('wishListedUids', arrayContains: user.uid)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(
                  child: ListView(
                    children: [
                      dummyBookWidget(),
                      dummyBookWidget(),
                      dummyBookWidget(),
                      dummyBookWidget(),
                    ],
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: OpenContainer(
                        closedShape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                        closedElevation: 1,
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (_, openContainer) {
                          return BookContainer(
                            ontap: openContainer,
                            snap: snapshot.data!.docs[index].data(),
                          );
                        },
                        openBuilder: (_, __) {
                          return BookDetailScreen(
                            snap: snapshot.data!.docs[index].data(),
                          );
                        },
                      ),
                    );
                  },
                  itemCount: snapshot.data!.docs.length,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
