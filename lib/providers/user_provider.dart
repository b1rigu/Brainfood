import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  MyUser? _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);
  final FirebaseAuthMethods _authMethods = FirebaseAuthMethods();

  MyUser get getUser => _user!;

  Future<void> refreshUser() async {
    MyUser user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
