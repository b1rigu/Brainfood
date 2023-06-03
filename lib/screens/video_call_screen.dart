import 'package:brainfood/utils/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    },
                    child: const Text("Open camera & microphone"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      roomId = await signaling.createRoom(_remoteRenderer);
                      textEditingController.text = roomId!;
                      setState(() {});
                    },
                    child: const Text("Create room"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add roomId
                      signaling.joinRoom(
                        textEditingController.text,
                        _remoteRenderer,
                      );
                    },
                    child: const Text("Join room"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                    },
                    child: const Text("Hangup"),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                    Expanded(child: RTCVideoView(_remoteRenderer)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Join the following Room: "),
                  Flexible(
                    child: TextFormField(
                      controller: textEditingController,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }
}
