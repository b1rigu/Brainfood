import 'package:cloud_firestore/cloud_firestore.dart';

class MyChatroomModel {
  final List<String> peopleIds;
  final String docId;
  final String combinedIds;
  final FieldValue lastChat;

  const MyChatroomModel({
    required this.peopleIds,
    required this.docId,
    required this.combinedIds,
    required this.lastChat,
  });

  Map<String, dynamic> toJson() => {
        "peopleIds": peopleIds,
        "docId": docId,
        "combinedIds": combinedIds,
        "lastChat": lastChat,
      };

  static MyChatroomModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return MyChatroomModel(
      peopleIds: snapshot['peopleIds'],
      docId: snapshot['docId'],
      combinedIds: snapshot['combinedIds'],
      lastChat: snapshot['lastChat'],
    );
  }
}
