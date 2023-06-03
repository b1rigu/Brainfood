import 'package:cloud_firestore/cloud_firestore.dart';

class BookComment {
  final String uid;
  final String userimageUrl;
  final String username;
  final FieldValue postTime;
  final String text;
  final String postId;

  BookComment({
    required this.uid,
    required this.userimageUrl,
    required this.username,
    required this.postTime,
    required this.text,
    required this.postId,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "userimageUrl": userimageUrl,
        "username": username,
        "postTime": postTime,
        "text": text,
        "postId": postId,
      };
}
