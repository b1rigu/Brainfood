import 'dart:async';

import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer _timer = Timer(const Duration(hours: 1), () {});

  @override
  void initState() {
    super.initState();
    addData();
    WidgetsBinding.instance.addObserver(this);
  }

  void addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
    setStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //active
      setStatus();
    } else {
      //offline
      Future.delayed(const Duration(minutes: 1), () {
        _timer.cancel();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void setStatus() async {
    await FirebaseAuthMethods().setStatus();
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      await FirebaseAuthMethods().setStatus();
    });
  }

  navigationTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: homeScreenItems[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        currentIndex: _currentIndex,
        onTap: navigationTapped,
        items: [
          //home posts
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.home),
            activeIcon: const Icon(IconlyBold.home),
            title: const Text("Home"),
            selectedColor: Colors.deepPurple[300],
          ),
          //booksell
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.bookmark),
            activeIcon: const Icon(IconlyBold.bookmark),
            title: const Text("Books"),
            selectedColor: Colors.orange[300],
          ),
          //pomodoro etc
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.discovery),
            activeIcon: const Icon(IconlyBold.discovery),
            title: const Text("News"),
            selectedColor: Colors.pink[300],
          ),
          //part time jobs
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.work),
            activeIcon: const Icon(IconlyBold.work),
            title: const Text("Jobs"),
            selectedColor: Colors.cyan[300],
          ),
          //Lessons
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.star),
            activeIcon: const Icon(IconlyBold.star),
            title: const Text("Lessons"),
            selectedColor: Colors.green[300],
          ),
        ],
      ),
    );
  }
}
