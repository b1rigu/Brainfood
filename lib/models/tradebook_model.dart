import 'package:cloud_firestore/cloud_firestore.dart';

class BookTrade {
  final String uid;
  final String userimageUrl;
  final String username;
  final FieldValue postTime;
  final List<String>? imageUrl;
  final String postId;
  final String bookname;
  final String price;
  final String userphonenumber;
  final String bookcaption;
  final String genre;
  final List<String>? tradeBooks;
  final List<String>? wishListedUids;

  BookTrade({
    required this.uid,
    required this.userimageUrl,
    required this.username,
    required this.postTime,
    required this.imageUrl,
    required this.postId,
    required this.bookname,
    required this.price,
    required this.userphonenumber,
    required this.bookcaption,
    required this.genre,
    required this.tradeBooks,
    required this.wishListedUids,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "userimageUrl": userimageUrl,
        "username": username,
        "postTime": postTime,
        "imageUrl": imageUrl,
        "postId": postId,
        "bookname": bookname,
        "price": price,
        "userphonenumber": userphonenumber,
        "bookcaption": bookcaption,
        "genre": genre,
        "booksToTrade": tradeBooks,
        "wishListedUids": wishListedUids,
      };
}
