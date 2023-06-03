import 'dart:typed_data';
import 'package:brainfood/models/book_comment_model.dart';
import 'package:brainfood/models/chat_model.dart';
import 'package:brainfood/models/chatroom_model.dart';
import 'package:brainfood/models/post_model.dart';
import 'package:brainfood/models/tradebook_model.dart';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/utils/firebase_storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //like
  Future<void> addlikes(String postid, MyUser user) async {
    DocumentReference doc = _firestore.collection('posts').doc(postid);
    await doc.update({
      'likedpeople': FieldValue.arrayUnion([user.uid])
    });
    await doc.update({'likes': FieldValue.increment(1)});
  }

  //delike
  Future<void> removelikes(String postid, MyUser user) async {
    DocumentReference doc = _firestore.collection('posts').doc(postid);
    await doc.update({
      'likedpeople': FieldValue.arrayRemove([user.uid])
    });
    await doc.update({'likes': FieldValue.increment(-1)});
  }

  //check if liked
  bool isliked(List<dynamic> likedpeople, MyUser user) {
    bool liked = false;
    for (var likedperson in likedpeople) {
      if (likedperson == user.uid) {
        liked = true;
      }
    }
    return liked;
  }

  bool isWishlisted(List<dynamic> wishListedUids, MyUser user) {
    bool liked = false;
    for (var uid in wishListedUids) {
      if (uid == user.uid) {
        liked = true;
      }
    }
    return liked;
  }

  //like
  Future<void> addtoWishList(String postid, MyUser user) async {
    DocumentReference doc = _firestore.collection('books').doc(postid);
    await doc.update({
      'wishListedUids': FieldValue.arrayUnion([user.uid])
    });
  }

  //delike
  Future<void> removefromWishList(String postid, MyUser user) async {
    DocumentReference doc = _firestore.collection('books').doc(postid);
    await doc.update({
      'wishListedUids': FieldValue.arrayRemove([user.uid])
    });
  }

  //get rooms
  Future<List<MyChatroomModel>> getRooms() async {
    List<MyChatroomModel> chatrooms = [];
    QuerySnapshot rooms = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('peopleIds', arrayContains: _auth.currentUser!.uid)
        .get();
    for (DocumentSnapshot room in rooms.docs) {
      MyChatroomModel chatroomModel = MyChatroomModel.fromSnap(room);
      chatrooms.add(chatroomModel);
    }
    return chatrooms;
  }

  Future<String> deleteRoom({
    required String roomId,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('chatrooms').doc(roomId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> createRoom({
    required String uid1,
    required String uid2,
  }) async {
    String res = "Some error occurred";
    try {
      MyChatroomModel model;
      String docId = const Uuid().v1();
      model = MyChatroomModel(
        peopleIds: [uid1, uid2],
        docId: docId,
        combinedIds: uid1 + uid2,
        lastChat: FieldValue.serverTimestamp(),
      );
      await _firestore.collection('users').doc(uid1).update({
        'friends': FieldValue.arrayUnion([uid2])
      });
      await _firestore.collection('users').doc(uid2).update({
        'friends': FieldValue.arrayUnion([uid1])
      });
      await _firestore.collection('chatrooms').doc(docId).set(model.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendMessage({
    required String uid,
    required String userimageUrl,
    required String username,
    List<Uint8List>? files,
    required String text,
    required String roomId,
  }) async {
    String res = "Some error occurred";
    List<String> photoUrl = [];
    try {
      MyChatModel myChatModel = MyChatModel(
        imageUrl: photoUrl,
        senderId: uid,
        profileUrl: userimageUrl,
        senderName: username,
        text: text,
        time: FieldValue.serverTimestamp(),
      );
      String docId = const Uuid().v1();
      if (files == null) {
        //file null
        await _firestore
            .collection('chatrooms')
            .doc(roomId)
            .collection('messages')
            .doc(docId)
            .set(myChatModel.toJson());
      } else {
        List<String> list = await StorageMethods()
            .uploadImageToStorage('messagePhotos', files, true);
        docId = list[0];
        list.removeAt(0);
        photoUrl.addAll(list);
        await _firestore
            .collection('chatrooms')
            .doc(roomId)
            .collection('messages')
            .doc(docId)
            .set(myChatModel.toJson());
      }
      await _firestore
          .collection('chatrooms')
          .doc(roomId)
          .update({'lastChat': FieldValue.serverTimestamp()});
      res = "success";
    } catch (err) {
      //error
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadComment({
    required String username,
    required String uid,
    required String userimageUrl,
    required String text,
  }) async {
    String res = "Some error occurred";
    try {
      String postId = const Uuid().v1();
      BookComment comment = BookComment(
          uid: uid,
          userimageUrl: userimageUrl,
          username: username,
          postTime: FieldValue.serverTimestamp(),
          text: text,
          postId: postId);
      await _firestore
          .collection('bookcomments')
          .doc(postId)
          .set(comment.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> sendEncryptedMessage({required String text}) async {
    try {
      await _firestore.collection('test').doc().set({"text": text});
    } catch (err) {
      //err
    }
  }

  //upload a book
  Future<String> uploadBook({
    required String username,
    required String uid,
    required String userimageUrl,
    required String userphonenumber,
    required String bookname,
    required String bookgenre,
    required String description,
    required String price,
    required List<String> booksToTrade,
    List<Uint8List>? file,
  }) async {
    String res = "Some error occurred";
    try {
      String postId = const Uuid().v1();
      BookTrade booktrade = BookTrade(
        uid: uid,
        userimageUrl: userimageUrl,
        username: username,
        postTime: FieldValue.serverTimestamp(),
        imageUrl: [],
        postId: postId,
        bookname: bookname,
        price: price,
        userphonenumber: userphonenumber,
        bookcaption: description,
        genre: bookgenre,
        tradeBooks: booksToTrade,
        wishListedUids: [],
      );
      List<String> imageUrls = [];
      if (file != null) {
        List<String> list =
            await StorageMethods().uploadImageToStorage('books', file, true);
        postId = list[0];
        list.removeAt(0);
        if (list.isNotEmpty) {
          for (int i = 0; i < list.length; i++) {
            imageUrls.add(list[i]);
          }
          booktrade = BookTrade(
            uid: uid,
            userimageUrl: userimageUrl,
            username: username,
            postTime: FieldValue.serverTimestamp(),
            imageUrl: imageUrls,
            postId: postId,
            bookname: bookname,
            price: price,
            userphonenumber: userphonenumber,
            bookcaption: description,
            genre: bookgenre,
            tradeBooks: booksToTrade,
            wishListedUids: [],
          );
        }
      }
      await _firestore.collection('books').doc(postId).set(booktrade.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPost(
    String caption,
    List<Uint8List>? files,
    String uid,
    String userimageUrl,
    String username,
    double aspectRatio,
  ) async {
    String res = "Some error occurred";
    try {
      MyPost post;
      List<String> list =
          await StorageMethods().uploadImageToStorage('posts', files, true);
      String postId = list[0];
      list.removeAt(0);

      if (list.isEmpty) {
        post = MyPost(
          username: username,
          userimageUrl: userimageUrl,
          uid: uid,
          caption: caption,
          postId: postId,
          postTime: Timestamp.now(),
          imageUrl: [],
          likes: 0,
          likedpeople: [],
          aspectRatio: aspectRatio,
        );
      } else {
        post = MyPost(
          username: username,
          userimageUrl: userimageUrl,
          uid: uid,
          caption: caption,
          postId: postId,
          postTime: Timestamp.now(),
          imageUrl: list,
          likes: 0,
          likedpeople: [],
          aspectRatio: aspectRatio,
        );
      }
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId, int pictureCount) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      await StorageMethods()
          .deleteImagefromStorage('posts', postId, true, pictureCount);
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('bookcomments').doc(postId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future saveComment(String postId, String text) async {
    try {
      await _firestore
          .collection('bookcomments')
          .doc(postId)
          .update({'text': text});
    } catch (err) {
      //err
    }
  }

  Future savePost(String postId, String text) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'caption': text});
    } catch (err) {
      //err
    }
  }
}
