import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String uid;
  final String userimageUrl;
  final String username;
  final FieldValue newsTime;
  final String imageUrl;
  final String newsId;
  final String title;
  final String text;
  final String genre;

  NewsModel({
    required this.uid,
    required this.userimageUrl,
    required this.username,
    required this.imageUrl,
    required this.genre,
    required this.newsTime,
    required this.newsId,
    required this.title,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "userimageUrl": userimageUrl,
        "username": username,
        "newsTime": newsTime,
        "imageUrl": imageUrl,
        "newsId": newsId,
        "title": title,
        "text": text,
        "genre": genre,
      };
}
