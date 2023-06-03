import 'package:cloud_firestore/cloud_firestore.dart';

class MyChatModel {
  final List<String> imageUrl;
  final String senderId;
  final String profileUrl;
  final String senderName;
  final String text;
  final FieldValue time;

  const MyChatModel({
    required this.imageUrl,
    required this.senderId,
    required this.profileUrl,
    required this.senderName,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "senderId": senderId,
        "profileUrl": profileUrl,
        "senderName": senderName,
        "text": text,
        "time": time,
      };

  static MyChatModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return MyChatModel(
        imageUrl: snapshot['imageUrl'],
        senderId: snapshot['senderId'],
        profileUrl: snapshot['profileUrl'],
        senderName: snapshot['senderName'],
        text: snapshot['text'],
        time: snapshot['time']);
  }
}
