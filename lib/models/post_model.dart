import 'package:cloud_firestore/cloud_firestore.dart';

class MyPost {
  final String uid;
  final String userimageUrl;
  final String caption;
  final String username;
  final Timestamp postTime;
  final List<String>? imageUrl;
  final String postId;
  final int likes;
  final List<dynamic> likedpeople;
  final double aspectRatio;

  const MyPost({
    required this.username,
    required this.userimageUrl,
    required this.uid,
    required this.postId,
    required this.caption,
    required this.postTime,
    this.imageUrl,
    required this.likes,
    required this.likedpeople,
    required this.aspectRatio,
  });

  static MyPost fromSnapPost(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    double aspect = snapshot['aspectRatio'].toDouble();
    return MyPost(
      username: snapshot['username'],
      userimageUrl: snapshot['userimageUrl'],
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      caption: snapshot['caption'],
      postTime: snapshot['postTime'],
      likes: snapshot['likes'],
      likedpeople: snapshot['likedpeople'],
      aspectRatio: aspect,
    );
  }

  Map<String, dynamic> toJson() => {
        'caption': caption,
        'uid': uid,
        'likes': likes,
        'likedpeople': likedpeople,
        'postId': postId,
        'postTime': postTime,
        'imageUrl': imageUrl,
        'username': username,
        'userimageUrl': userimageUrl,
        'aspectRatio': aspectRatio,
      };
}
