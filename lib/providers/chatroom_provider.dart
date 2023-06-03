import 'package:brainfood/models/chatroom_model.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:flutter/material.dart';

class ChatRoomProvider with ChangeNotifier {
  List<MyChatroomModel> chatroomModel = [];
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  List<MyChatroomModel> get getChatroom => chatroomModel;

  Future<void> refreshChatrooms() async {
    List<MyChatroomModel> chatrooms = await _firestoreMethods.getRooms();
    chatroomModel = chatrooms;
    notifyListeners();
  }
}
