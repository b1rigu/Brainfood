import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class AddChatPeople extends StatefulWidget {
  const AddChatPeople({Key? key}) : super(key: key);

  @override
  State<AddChatPeople> createState() => _AddChatPeopleState();
}

class _AddChatPeopleState extends State<AddChatPeople> {
  List<dynamic> availableUsers = [];
  List<dynamic> searchResult = [];
  final TextEditingController _searchController = TextEditingController();
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

  void getData() async {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> users = await fstore
        .collection('users')
        .where('uid', isNotEqualTo: _user.uid)
        .get();
    if (users.size > 0) {
      for (int i = 0; i < users.size; i++) {
        Map<String, dynamic> docdata = users.docs[i].data();
        var userId = docdata['uid'];
        QuerySnapshot chatrooms1 = await fstore
            .collection('chatrooms')
            .where('combinedIds', isEqualTo: _user.uid + userId)
            .get();
        QuerySnapshot chatrooms2 = await fstore
            .collection('chatrooms')
            .where('combinedIds', isEqualTo: userId + _user.uid)
            .get();
        if (chatrooms1.size < 1 && chatrooms2.size < 1) {
          availableUsers.add(docdata);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void updateList(String value) {
    searchResult.clear();
    setState(() => _isLoading = true);
    if (value == '') {
      //empty
    } else {
      for (var user in availableUsers) {
        if (user['username'].toLowerCase().contains(value.toLowerCase())) {
          searchResult.add(user);
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, false),
      body: Column(
        children: [
          searchWidget(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return searchedPeople(index);
              },
              itemCount: searchResult.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          updateList(value);
        },
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
          hintText: 'Search people...',
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

  void createRoom(uid2) async {
    await FirestoreMethods().createRoom(uid1: _user.uid, uid2: uid2);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget searchedPeople(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          createRoom(searchResult[index]['uid']);
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
                      searchResult[index]['photoUrl']),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 170,
                  child: Text(
                    searchResult[index]['username'],
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
}
