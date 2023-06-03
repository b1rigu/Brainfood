import 'package:flutter/material.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({Key? key}) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
      ),
      body: SafeArea(
        child: Stack(
          children: [],
        ),
      ),
    );
  }
}
