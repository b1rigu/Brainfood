import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/pick_image.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

enum MySteps {
  firstScreen,
  secondScreen,
  thirdScreen,
}

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final _cropcontroller = CropController();
  List<Uint8List> selectedImages = [];
  double aspectRatio = 0.0;
  bool _isLoading = false;
  List<List<AssetEntity>> picturesList = [];
  List<AssetPathEntity> paths = [];
  List<String> folderNames = [];
  List<int> selectedPicsOnList = [];
  String selectedItem = '';
  int selectedIndex = 0;
  MySteps step = MySteps.firstScreen;

  @override
  void initState() {
    super.initState();
    checkPermission();
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

  void publishPost() async {
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    setState(() {
      _isLoading = true;
    });
    String res = await FirestoreMethods().uploadPost(
      _postController.text,
      selectedImages,
      user.uid,
      user.photoUrl,
      user.username,
      aspectRatio,
    );
    if (res == "success") {
      //success
      setState(() {
        _isLoading = false;
      });
      openHomePage();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      showSnackBar(res, context, true);
    }
  }

  void openHomePage() {
    Navigator.of(context).pop();
  }

  String checkBoxes() {
    String res = 'alldone';
    if (_postController.text.length > 2000) {
      //exceeded
      res = 'error';
      showSnackBar('You have exceeded the max character limit', context, true);
    } else if (_postController.text.isEmpty) {
      //no text
      res = 'error';
      showSnackBar('Post cannot be empty', context, true);
    }
    return res;
  }

  void addPictoList(int index) async {
    Uint8List? picture = await picturesList[selectedIndex][index].originBytes;
    Uint8List compressed = await FlutterImageCompress.compressWithList(
      picture!,
      quality: 20,
    );
    selectedImages.add(compressed);
    selectedPicsOnList.add(index);
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

  Widget cropper() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Crop(
        image: selectedImages.last,
        controller: _cropcontroller,
        onCropped: (image) {
          selectedImages.removeLast();
          selectedImages.add(image);
          setState(() {});
          // do something with image data
        },
        initialArea: const Rect.fromLTWH(240, 212, 800, 600),
        initialAreaBuilder: (rect) => Rect.fromLTRB(
            rect.left + 10, rect.top + 10, rect.right - 10, rect.bottom - 10),
        aspectRatio: 1.0,
        baseColor: Colors.white,
        maskColor: Colors.black,
        onMoved: (newRect) {
          // do something with current cropping area.
        },
        onStatusChanged: (status) {
          // do something with current CropStatus
          if (status == CropStatus.ready) {
            setState(() {});
          }
        },
        cornerDotBuilder: (size, edgeAlignment) =>
            const DotControl(color: Colors.transparent),
        interactive: true,
        fixArea: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        final discard = await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text('Please Confirm'),
                content: const Text('Are you sure you want to discard?'),
                actions: [
                  // The "Yes" button
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              );
            });
        return discard!;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Create Post',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: screens(),
      ),
    );
  }

  Widget screens() {
    double height = MediaQuery.of(context).size.height;
    if (step == MySteps.firstScreen) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            postFieldWidget(),
            MyTextButton(
              text: 'Continue',
              onPressed: () {
                //publishPost();
                setState(() {
                  step = MySteps.secondScreen;
                });
              },
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromRGBO(247, 86, 114, 1),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.2,
            ),
          ],
        ),
      );
    } else if (step == MySteps.secondScreen) {
      return Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                postPictures(),
                // MyTextButton(
                //   text: 'Crop',
                //   onPressed: () {
                //     _cropcontroller.crop();
                //   },
                //   gradient: const LinearGradient(
                //     colors: [
                //       Color.fromRGBO(149, 117, 205, 1),
                //       Color.fromRGBO(247, 86, 114, 1),
                //     ],
                //   ),
                // ),
                Row(
                  children: [
                    Expanded(
                      child: MyTextButton(
                        text: 'Go back',
                        onPressed: () {
                          setState(() {
                            step = MySteps.firstScreen;
                          });
                        },
                        boxcolor: Colors.grey[200],
                        textcolor: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: MyTextButton(
                        text: 'Publish',
                        onPressed: () {
                          String check = checkBoxes();
                          if (check == 'alldone') {
                            publishPost();
                            setState(() {
                              step = MySteps.thirdScreen;
                            });
                          }
                        },
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(149, 117, 205, 1),
                            Color.fromRGBO(247, 86, 114, 1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.2,
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
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
              );
            },
            minChildSize: 0.25,
            initialChildSize: 0.25,
            maxChildSize: 0.9,
            snap: true,
          ),
        ],
      );
    }
    return Column(
      children: [
        Lottie.asset('assets/uploadfiles.json'),
        const Center(
            child: Text('Currently publishing your post to our servers'))
      ],
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

  Widget cropSection() {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: const Color.fromRGBO(149, 117, 205, 1)),
      ),
      child: InteractiveViewer(
        onInteractionEnd: (details) {
          Image image = Image.memory(selectedImages.last);
        },
        minScale: 0.1,
        maxScale: 5.0,
        constrained: false,
        child: Image(
          image: MemoryImage(selectedImages.last),
        ),
      ),
    );
  }

  Widget postPictures() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      height: selectedImages.isNotEmpty ? width : height * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedImages.isNotEmpty
            ? cropSection()
            : Container(
                height: double.infinity,
                width: width,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromRGBO(149, 117, 205, 1)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    'No image selected!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget postFieldWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        textAlignVertical: TextAlignVertical.top,
        controller: _postController,
        keyboardType: TextInputType.multiline,
        minLines: 6,
        maxLines: 12,
        maxLength: 2000,
        maxLengthEnforcement: MaxLengthEnforcement.none,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Create a great post today',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              _postController.clear();
              FocusScope.of(context).unfocus();
            },
            icon: const Icon(
              Icons.close,
              color: Color.fromRGBO(149, 117, 205, 1),
            ),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
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
}
