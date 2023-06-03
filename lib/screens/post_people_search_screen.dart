import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/profile_screen.dart';
import 'package:brainfood/widgets/post_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class PostPeopleSearchScreen extends StatefulWidget {
  const PostPeopleSearchScreen({Key? key}) : super(key: key);

  @override
  State<PostPeopleSearchScreen> createState() => _PostPeopleSearchScreenState();
}

class _PostPeopleSearchScreenState extends State<PostPeopleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> postSearchResults = [];
  List<dynamic> userSearchResults = [];
  bool _isLoading = false;
  List<dynamic> posts = [];
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void getData() async {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    posts.clear();
    users.clear();
    QuerySnapshot<Map<String, dynamic>> allPosts = await fstore
        .collection('posts')
        .orderBy('postTime', descending: true)
        .get();
    QuerySnapshot<Map<String, dynamic>> allUsers = await fstore
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .get();
    for (var post in allPosts.docs) {
      var myPost = post.data();
      posts.add(myPost);
    }
    for (var user in allUsers.docs) {
      var myUser = user.data();
      users.add(myUser);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      return searchedPeople(index);
                    },
                    itemCount: userSearchResults.length,
                  ),
                  _searchController.text.isNotEmpty
                      ? userSearchResults.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        158, 158, 158, 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('See all')),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 100,
                              child: Center(child: Text('No User found')),
                            )
                      : const SizedBox.shrink(),
                  _searchController.text.isNotEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(thickness: 1.0),
                        )
                      : const SizedBox.shrink(),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      return PostContainer(snap: postSearchResults[index]);
                    },
                    itemCount: postSearchResults.length,
                  ),
                  _searchController.text.isNotEmpty
                      ? postSearchResults.isNotEmpty
                          ? const SizedBox.shrink()
                          : const SizedBox(
                              height: 100,
                              child: Center(child: Text('No Post found')),
                            )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            searchWidget(),
          ],
        ),
      ),
    );
  }

  void updateList(String value) {
    postSearchResults.clear();
    userSearchResults.clear();
    setState(() => _isLoading = true);
    if (value == '') {
      //empty
    } else {
      for (var post in posts) {
        if (post['caption'].toLowerCase().contains(value.toLowerCase()) ||
            post['username'].toLowerCase().contains(value.toLowerCase())) {
          postSearchResults.add(post);
        }
      }
      for (var user in users) {
        if (user['username'].toLowerCase().contains(value.toLowerCase())) {
          userSearchResults.add(user);
          if (userSearchResults.length == 2) {
            break;
          }
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Widget searchedPeople(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          openPersonProfile(index);
        },
        child: Container(
          height: 100,
          color: Colors.white,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: CachedNetworkImageProvider(
                      userSearchResults[index]['photoUrl']),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 170,
                  child: Text(
                    userSearchResults[index]['username'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          updateList(value);
        },
        autofocus: true,
        textAlignVertical: TextAlignVertical.top,
        controller: _searchController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            IconlyLight.search,
            color: Colors.black87,
            size: 28,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search posts and people...',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.of(context).pop();
              } else {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                updateList('');
              }
            },
            icon: const Icon(
              Icons.close,
              color: Color.fromRGBO(149, 117, 205, 1),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  void openPersonProfile(index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: userSearchResults[index]['uid'],
          userImageUrl: userSearchResults[index]['photoUrl'],
          username: userSearchResults[index]['username'],
        ),
      ),
    );
  }
}
