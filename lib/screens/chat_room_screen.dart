import 'dart:typed_data';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/screens/video_call_screen.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/pick_image.dart';
import 'package:brainfood/widgets/active_status_widget.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/carousel.dart';
import 'package:brainfood/widgets/fullscreen_slider_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomScreen extends StatefulWidget {
  final docId;
  final MyUser senderInfo;
  const ChatRoomScreen({
    Key? key,
    required this.docId,
    required this.senderInfo,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  MyUser _user = MyUser(
      email: "",
      uid: "",
      photoUrl:
          "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
      username: "SleepingBeauty",
      friends: [],
      lastActive: Timestamp.now(),
      starred: []);
  final TextEditingController _textController = TextEditingController();
  List<Uint8List> selectedImages = [];
  String timeAgo = '';
  bool active = false;
  var docs;
  bool galleryOpen = false;
  List<List<AssetEntity>> picturesList = [];
  List<AssetPathEntity> paths = [];
  List<String> folderNames = [];
  List<int> selectedPicsOnList = [];
  String selectedItem = '';
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    gettimeago();
    checkPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  void gettimeago() {
    DateTime lastActiveTime = widget.senderInfo.lastActive.toDate();
    timeAgo = timeago.format(lastActiveTime, locale: 'en_short').toString();
  }

  void getImages() async {
    paths = await PhotoManager.getAssetPathList();
    for (int i = 0; i < paths.length; i++) {
      folderNames.add(paths[i].name);
      List<AssetEntity> pictures =
          await paths[i].getAssetListPaged(page: 0, size: 100000);
      picturesList.add(pictures);
    }
    setState(() {
      selectedItem = folderNames[0];
    });
  }

  void checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Granted.
      getImages();
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }
  }

  void selectImage() async {
    Uint8List? im = await pickImage(true, false);
    if (im != null) {
      Uint8List result = await FlutterImageCompress.compressWithList(
        im,
        quality: 20,
      );
      selectedImages.add(result);
    }
    setState(() {});
  }

  void addPictoList(int index) async {
    Uint8List? picture = await picturesList[selectedIndex][index].originBytes;
    Uint8List compressed = await FlutterImageCompress.compressWithList(
      picture!,
      quality: 20,
    );
    selectedImages.add(compressed);
    selectedPicsOnList.add(index);
    double aspectRatio = 0.0;
    Image(image: MemoryImage(selectedImages[0]))
        .image
        .resolve(const ImageConfiguration())
        .addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          int width = info.image.width;
          int height = info.image.height;
          aspectRatio = width / height;
        },
      ),
    );
    setState(() {});
  }

  void unselectPic(int index) {
    int picIndex = selectedPicsOnList.indexWhere((element) => element == index);
    selectedPicsOnList.removeAt(picIndex);
    selectedImages.removeAt(picIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<UserProvider>(context, listen: false).getUser;
    return Scaffold(
      appBar: appBar(context, false),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.docId)
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      docs = snapshot.data!.docs;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        itemBuilder: (context, index) {
                          if (snapshot.data!.docs[index].data()['senderId'] ==
                              _user.uid) {
                            return myTextWidget(
                              snapshot.data!.docs[index].data(),
                              index,
                            );
                          }
                          return senderTextWidget(
                            snapshot.data!.docs[index].data(),
                            index,
                          );
                        },
                        itemCount: snapshot.data != null
                            ? snapshot.data!.docs.length
                            : 0,
                      );
                    },
                  ),
                ),
                headerWidget(),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.top,
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Type here...',
                            suffixIcon: IconButton(
                              splashRadius: 18.0,
                              onPressed: () {
                                _textController.clear();
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Color.fromRGBO(149, 117, 205, 1),
                              ),
                            ),
                            labelStyle: const TextStyle(color: Colors.black54),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(149, 117, 205, 1)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(149, 117, 205, 1)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() {
                                galleryOpen = !galleryOpen;
                              });
                            },
                            child:
                                const Icon(IconlyLight.paper_upload, size: 28),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              sendMessage();
                            },
                            child: const Icon(IconlyLight.send, size: 28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                galleryOpen
                    ? Container(
                        height: 300,
                        color: Colors.white,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  folderSelectionWidget(),
                                  const SizedBox(width: 24),
                                  GestureDetector(
                                    onTap: () {
                                      selectImage();
                                    },
                                    child: const Icon(IconlyLight.camera),
                                  ),
                                ],
                              ),
                            ),
                            SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (selectedPicsOnList.contains(index)) {
                                    return selectedPicture(index);
                                  }
                                  return nonSelectedPicture(index);
                                },
                                childCount: picturesList.isEmpty
                                    ? 0
                                    : picturesList[selectedIndex].length,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 3.0,
                                mainAxisSpacing: 3.0,
                                crossAxisCount: 4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedPicture(int index) {
    return GestureDetector(
      onTap: () {
        unselectPic(index);
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AssetEntityImage(
            picturesList[selectedIndex][index],
            isOriginal: false,
            height: 100,
            width: 100,
            thumbnailSize: const ThumbnailSize.square(200),
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.white38,
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.green[300],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(width: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nonSelectedPicture(int index) {
    return GestureDetector(
      onTap: () {
        addPictoList(index);
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AssetEntityImage(
            picturesList[selectedIndex][index],
            isOriginal: false,
            height: 100,
            width: 100,
            thumbnailSize: const ThumbnailSize.square(200),
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(width: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget folderSelectionWidget() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 12.0),
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      primary: false,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(IconlyLight.folder),
                          onTap: () {
                            setState(() {
                              selectedItem = folderNames[index];
                              selectedIndex = index;
                            });
                            Navigator.of(context).pop();
                          },
                          title: Text(folderNames[index]),
                        );
                      },
                      itemCount: folderNames.length,
                    ),
                  );
                },
              );
            },
            child: Text(
              selectedItem.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const Icon(Icons.arrow_downward_rounded),
      ],
    );
  }

  Widget headerWidget() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderInfo.uid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data!.data();
          final DateTime lastActiveTime = data!['lastActive'].toDate();
          final DateTime timeNow = DateTime.now();
          final int difference = timeNow.difference(lastActiveTime).inMinutes;
          if (difference < 6) {
            active = true;
          } else {
            active = false;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          CachedNetworkImageProvider(data['photoUrl']),
                    ),
                    Positioned(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          ActiveStatusWidget(active: active, radius: 7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['username'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      active
                          ? const Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Text(
                              'Last active $timeAgo ago',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              //videocall
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VideoCallScreen(),
                    ),
                  );
                },
                child: const Icon(IconlyLight.video),
              ),

              const SizedBox(width: 10),
              //voice call
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const VoiceCallScreen(),
                    //   ),
                    // );
                  },
                  child: const Icon(IconlyLight.calling),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void openFullscreenView(index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullscreenSlider(isChat: true, docs: docs, index: 0),
      ),
    );
  }

  Widget senderTextWidget(snap, index) {
    String dateString = getDateString(snap);
    bool showTime = false;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 200,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snap['text'],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      snap['imageUrl'].isEmpty
                          ? const SizedBox.shrink()
                          : const SizedBox(height: 8),
                      snap['imageUrl'].isEmpty
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () {
                                openFullscreenView(index);
                              },
                              child: SizedBox(
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: snap['imageUrl'][0],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(dateString),
            ),
          ],
        ),
      ),
    );
  }

  Widget myTextWidget(snap, index) {
    String dateString = getDateString(snap);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 250,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    snap['text'].isNotEmpty
                        ? Text(
                            snap['text'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox.shrink(),
                    snap['imageUrl'].isEmpty
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 8),
                    snap['imageUrl'].isEmpty
                        ? const SizedBox.shrink()
                        : snap['imageUrl'].length < 2
                            ? GestureDetector(
                                onTap: () {
                                  openFullscreenView(index);
                                },
                                child: SizedBox(
                                  height: 300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: snap['imageUrl'][0],
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        height: 300,
                                        color: Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 2.0,
                                        mainAxisSpacing: 2.0),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      openFullscreenView(index);
                                    },
                                    child: SizedBox(
                                      height: 300,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: snap['imageUrl'][index],
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
                                            height: 300,
                                            color: Colors.grey[200],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: snap['imageUrl'].length,
                              ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(dateString),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    String text = _textController.text.trim();
    _textController.clear();
    selectedPicsOnList.clear();
    List<Uint8List> duplicateImages = [];
    duplicateImages.addAll(selectedImages);
    selectedImages.clear();
    if (text.isNotEmpty && duplicateImages.isEmpty) {
      await FirestoreMethods().sendMessage(
        uid: _user.uid,
        userimageUrl: _user.photoUrl,
        username: _user.username,
        text: text,
        roomId: widget.docId,
      );
    } else if (text.isNotEmpty && duplicateImages.isNotEmpty) {
      setState(() {});
      await FirestoreMethods().sendMessage(
        files: duplicateImages,
        uid: _user.uid,
        userimageUrl: _user.photoUrl,
        username: _user.username,
        text: text,
        roomId: widget.docId,
      );
    } else if (text.isEmpty && duplicateImages.isNotEmpty) {
      setState(() {});
      await FirestoreMethods().sendMessage(
        files: duplicateImages,
        uid: _user.uid,
        userimageUrl: _user.photoUrl,
        username: _user.username,
        text: text,
        roomId: widget.docId,
      );
    } else {
      //empty text
    }
  }

  String getDateString(snap) {
    String dateString = '00:00 AM';
    if (snap['time'] != null) {
      final Timestamp timestamp = snap['time'] as Timestamp;
      final DateTime dateTime = timestamp.toDate();
      DateTime today = DateTime.now();
      String todayLocal = DateFormat('yyyy-MM-dd').format(today);
      String timeServer = DateFormat('yyyy-MM-dd').format(dateTime);
      if (todayLocal == timeServer) {
        dateString = DateFormat('hh:mm a').format(dateTime);
      } else {
        dateString = DateFormat('y/M/d hh:mm a').format(dateTime);
      }
    }
    return dateString;
  }
}
