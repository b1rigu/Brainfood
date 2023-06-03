import 'dart:async';

import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PeopleWhoLikedScreen extends StatefulWidget {
  const PeopleWhoLikedScreen({Key? key}) : super(key: key);

  @override
  State<PeopleWhoLikedScreen> createState() => _PeopleWhoLikedScreenState();
}

class _PeopleWhoLikedScreenState extends State<PeopleWhoLikedScreen> {
  StreamController<List<String>> _images = StreamController<List<String>>();

  // Stream<List<dynamic>> starredStream() async* {
  //   MyUser user = Provider.of<UserProvider>(context).getUser;
  //   List<dynamic> userStream = user.starred;
  //   yield userStream;
  // }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    return Scaffold(
      appBar: appBar(context, false),
      body: Column(
        children: [
          // StreamBuilder(
          //   stream: starredStream(),
          //   builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Expanded(
          //         child: GridView(
          //           gridDelegate:
          //               const SliverGridDelegateWithFixedCrossAxisCount(
          //             crossAxisCount: 2,
          //             childAspectRatio: 4 / 5,
          //           ),
          //           children: [
          //             dummyPersonWidget(),
          //             dummyPersonWidget(),
          //             dummyPersonWidget(),
          //             dummyPersonWidget(),
          //             dummyPersonWidget(),
          //             dummyPersonWidget(),
          //           ],
          //         ),
          //       );
          //     }
          //     return Expanded(
          //       child: GridView.builder(
          //         itemBuilder: (context, index) {
          //           return personWidget(snapshot.data!);
          //         },
          //         itemCount: snapshot.data!.length,
          //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //           crossAxisCount: 2,
          //           childAspectRatio: 4 / 5,
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget dummyPersonWidget() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget personWidget(snap) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl:
              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.jordanharbinger.com%2Fwp-content%2Fuploads%2F2018%2F09%2Fbe-the-most-interesting.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
