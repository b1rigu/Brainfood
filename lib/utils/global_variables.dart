import 'package:brainfood/screens/book_screen.dart';
import 'package:brainfood/screens/home_screen.dart';
import 'package:brainfood/screens/job_screen.dart';
import 'package:brainfood/screens/lesson_screen.dart';
import 'package:brainfood/screens/meet_friends_chats_screen.dart';
import 'package:brainfood/screens/meet_friends_people_who_liked.dart';
import 'package:brainfood/screens/meet_friends_screen.dart';
import 'package:brainfood/screens/news_screen.dart';
import 'package:flutter/material.dart';

List<Widget> homeScreenItems = [
  const HomeScreen(),
  const BookScreen(),
  const NewsScreen(),
  const JobScreen(),
  const LessonScreen(),
];

List<Widget> meetFriendsItems = [
  const MeetFriendsScreen(),
  const PeopleWhoLikedScreen(),
  const MeetFriendsChat(),
];

Widget comingsoon = const Scaffold(
  body: Center(
    child: Text('gg'),
  ),
);
