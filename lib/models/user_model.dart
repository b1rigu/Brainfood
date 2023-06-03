import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final List friends;
  final String phonenumber;
  final Timestamp lastActive;
  final List<dynamic> starred;

  const MyUser({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.friends,
    this.phonenumber = '',
    required this.lastActive,
    required this.starred,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "photoUrl": photoUrl,
        "email": email,
        "friends": friends,
        "lastActive": lastActive,
        "starred": starred,
      };

  static MyUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    if (snapshot['phonenumber'] != null) {
      return MyUser(
        username: snapshot['username'],
        uid: snapshot['uid'],
        photoUrl: snapshot['photoUrl'],
        email: snapshot['email'],
        friends: snapshot['friends'],
        phonenumber: snapshot['phonenumber'],
        lastActive: snapshot['lastActive'],
        starred: snapshot['starred'],
      );
    } else {
      return MyUser(
        username: snapshot['username'],
        uid: snapshot['uid'],
        photoUrl: snapshot['photoUrl'],
        email: snapshot['email'],
        friends: snapshot['friends'],
        lastActive: snapshot['lastActive'],
        starred: snapshot['starred'],
      );
    }
  }
}
