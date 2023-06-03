import 'dart:typed_data';

import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/pick_image.dart';
import 'package:brainfood/utils/secure_storage.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

enum MySteps {
  firstScreen,
  secondScreen,
  thirdScreen,
  fourthScreen,
}

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({Key? key}) : super(key: key);

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _booknameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bookpriceController = TextEditingController();
  final TextEditingController _booktradeController = TextEditingController();

  List<String> bookGenres = [
    'БАЙГАЛИЙН ШИНЖЛЭЛ',
    'БИЗНЕС, ЭДИЙН ЗАСАГ',
    'БЭЛГИЙН НОМ',
    'ГАЗРЫН ЗУРАГ',
    'КОМИК, МАНГА',
    'МАТЕМАТИК, ШИНЖЛЭХ УХААН',
    'НАМТАР, ДУРСАМЖ',
    'НАРИЙН МЭРГЭЖИЛ, ҮЙЛДВЭРЛЭЛ',
    'НИЙГМИЙН ШИНЖЛЭХ УХААН',
    'НЭВТЭРХИЙ ТОЛЬ, ГАРЫН АВЛАГА',
    'ӨӨРТӨӨ ТУСЛАХ',
    'СПОРТ',
    'СУРАХ БИЧИГ',
    'ТҮҮХ',
    'УРАН ЗОХИОЛ',
    'УРЛАГ, СОЁЛ, ГЭРЭЛ ЗУРАГ',
    'ХОББИ, ЧӨЛӨӨТ ЦАГ, ХООЛ',
    'ХӨДӨӨ АЖ АХУЙ',
    'ХУУЛЬ, ЭРХ ЗҮЙ',
    'ХҮҮХДИЙН НОМ',
    'ХЭЛ, ТОЛЬ БИЧИГ',
    'ШАШИН',
    'ЭРҮҮЛ МЭНД, ГЭР БҮЛ',
    'БУСАД',
  ];
  String chosenGenre = 'Select book genre';
  MySteps step = MySteps.firstScreen;
  double percent = 0.25;
  List<String> tradeBooks = [];
  List<Uint8List> selectedImages = [];
  bool uploading = false;

  @override
  void dispose() {
    super.dispose();
    _booknameController.dispose();
    _descriptionController.dispose();
    _bookpriceController.dispose();
    _booktradeController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getDraft();
  }

  void getDraft() async {
    final bookname = await MySecureStorage().getBookname() ?? '';
    final bookdescription = await MySecureStorage().getBookdescription() ?? '';
    final bookgenre =
        await MySecureStorage().getBookgenre() ?? 'Select book genre';
    final bookprice = await MySecureStorage().getBookprice() ?? '';
    _booknameController.text = bookname;
    _descriptionController.text = bookdescription;
    chosenGenre = bookgenre;
    _bookpriceController.text = bookprice;
  }

  void selectImage() async {
    Uint8List? im;
    List<Uint8List> images = [];
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(IconlyLight.camera),
              title: const Text('Select using camera'),
              onTap: () async {
                im = await pickImage(true, false);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(IconlyLight.category),
              title: const Text('Select from gallery'),
              onTap: () async {
                images = await pickImage(false, true);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (im != null) {
      setState(() {
        selectedImages.add(im!);
      });
    } else if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
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
                actions: [
                  TextButton(
                    onPressed: () async {
                      await MySecureStorage().saveBookDraft(
                        _booknameController.text,
                        _descriptionController.text,
                        chosenGenre,
                        _bookpriceController.text,
                      );
                      if (!mounted) return;
                      // Close the dialog
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Draft',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await MySecureStorage().deleteAll();
                      if (!mounted) return;
                      // Close the dialog
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Discard',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      'Cancel',
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
            'Publish book',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.02,
              ),
              LinearPercentIndicator(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                animation: true,
                animateFromLastPercent: true,
                lineHeight: 20,
                percent: percent,
                barRadius: const Radius.circular(12),
                progressColor: Colors.deepPurple[300],
                backgroundColor: Colors.deepPurple[100],
              ),
              screens(),
            ],
          ),
        ),
      ),
    );
  }

  Widget postButtons() {
    return Row(
      children: [
        Expanded(
          child: MyTextButton(
            text: 'Remove all',
            onPressed: () {
              setState(() {
                selectedImages.clear();
              });
            },
            boxcolor: Colors.white,
            textcolor: Colors.black,
            bouncingEnabled: false,
          ),
        ),
        Expanded(
          child: MyTextButton(
            text: 'Add more',
            onPressed: () {
              selectImage();
            },
            boxcolor: Colors.white,
            textcolor: Colors.black,
            bouncingEnabled: false,
          ),
        ),
      ],
    );
  }

  Widget postPictures() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      height: selectedImages.isNotEmpty ? 380 : height * 0.1,
      child: Padding(
        padding: selectedImages.isNotEmpty
            ? const EdgeInsets.only(
                top: 8.0,
                right: 8.0,
                left: 8.0,
              )
            : const EdgeInsets.all(16),
        child: selectedImages.isNotEmpty
            ? GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: selectedImages.length == 1 ? 1 : 2,
                ),
                itemBuilder: (context, index) {
                  if (index > 2) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromRGBO(149, 117, 205, 1)),
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  alignment: FractionalOffset.topCenter,
                                  image: MemoryImage(selectedImages[3]),
                                )),
                          ),
                        ),
                        selectedImages.length > 4
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        selectedImages.length > 4
                            ? Center(
                                child: Text(
                                  '+${selectedImages.length - 4}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 36,
                                    color: Colors.black87,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(149, 117, 205, 1)),
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            image: MemoryImage(selectedImages[index]),
                          )),
                    ),
                  );
                },
                itemCount:
                    selectedImages.length > 4 ? 4 : selectedImages.length,
              )
            : GestureDetector(
                onTap: () {
                  selectImage();
                },
                child: Container(
                  height: double.infinity,
                  width: width,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(149, 117, 205, 1)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      'No image selected! Tap to select',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget screens() {
    double height = MediaQuery.of(context).size.height;
    if (step == MySteps.firstScreen) {
      return Column(
        children: [
          SizedBox(
            height: height * 0.07,
          ),
          MyTextField(
            keyboardType: TextInputType.text,
            labelText: 'Book name',
            controller: _booknameController,
            useFormatter: false,
            onpressX: () {
              _booknameController.clear();
            },
          ),
          SizedBox(
            height: height * 0.04,
          ),
          bookFieldWidget(),
          SizedBox(
            height: height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    FocusScope.of(context).unfocus();
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        primary: false,
                        itemBuilder: (context, index) {
                          if (chosenGenre == bookGenres[index]) {
                            return ListTile(
                              dense: true,
                              selected: true,
                              selectedColor: Colors.white,
                              selectedTileColor: Colors.deepPurple[300],
                              leading: const Icon(IconlyLight.bookmark),
                              onTap: () {
                                setState(() {
                                  chosenGenre = bookGenres[index];
                                });
                                Navigator.of(context).pop();
                              },
                              title: Text(bookGenres[index]),
                            );
                          }
                          return ListTile(
                            dense: true,
                            leading: const Icon(IconlyLight.bookmark),
                            onTap: () {
                              setState(() {
                                chosenGenre = bookGenres[index];
                              });
                              Navigator.of(context).pop();
                            },
                            title: Text(bookGenres[index]),
                          );
                        },
                        itemCount: bookGenres.length,
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromRGBO(149, 117, 205, 1)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            chosenGenre,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        IconlyLight.arrow_down_2,
                        color: Color.fromRGBO(149, 117, 205, 1),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.05,
          ),
          MyTextButton(
            text: 'Continue',
            onPressed: () {
              setState(() {
                step = MySteps.secondScreen;
                percent = 0.5;
              });
            },
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(149, 117, 205, 1),
                Color.fromRGBO(247, 86, 114, 1),
              ],
            ),
          ),
        ],
      );
    } else if (step == MySteps.secondScreen) {
      return Column(
        children: [
          SizedBox(
            height: height * 0.07,
          ),
          MyTextField(
            keyboardType: TextInputType.number,
            controller: _bookpriceController,
            labelText: 'Price',
            isNumber: true,
            onpressX: () {
              _bookpriceController.clear();
            },
            maxLength: 20,
          ),
          SizedBox(
            height: height * 0.04,
          ),
          MyTextField(
            keyboardType: TextInputType.text,
            controller: _booktradeController,
            labelText: 'Add book to trade and press +',
            useFormatter: false,
            onpressX: () {
              _booktradeController.clear();
            },
          ),
          SizedBox(
            height: height * 0.02,
          ),
          tradeBooks.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              '- ${tradeBooks[index]}',
                            ),
                            const Spacer(),
                            Material(
                              color: Colors.grey[200],
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    tradeBooks.removeAt(index);
                                  });
                                },
                                child: const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Icon(
                                    IconlyLight.delete,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: tradeBooks.length,
                )
              : const SizedBox.shrink(),
          SizedBox(
            height: height * 0.02,
          ),
          MyTextButton(
            text: '+ Add book +',
            onPressed: () {
              FocusScope.of(context).unfocus();
              addBookToList();
            },
            boxcolor: Colors.grey[200],
            textcolor: Colors.black,
          ),
          SizedBox(
            height: height * 0.05,
          ),
          Row(
            children: [
              Expanded(
                child: MyTextButton(
                  text: 'Go back',
                  onPressed: () {
                    setState(() {
                      percent = 0.25;
                      step = MySteps.firstScreen;
                    });
                  },
                  boxcolor: Colors.grey[200],
                  textcolor: Colors.black,
                ),
              ),
              Expanded(
                child: MyTextButton(
                  text: 'Continue',
                  onPressed: () {
                    setState(() {
                      percent = 0.75;
                      step = MySteps.thirdScreen;
                    });
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
        ],
      );
    } else if (step == MySteps.thirdScreen) {
      return Column(
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          postPictures(),
          selectedImages.isNotEmpty ? postButtons() : const SizedBox.shrink(),
          Row(
            children: [
              Expanded(
                child: MyTextButton(
                  text: 'Go back',
                  onPressed: () {
                    setState(() {
                      percent = 0.5;
                      step = MySteps.secondScreen;
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
                      publishBook();
                      setState(() {
                        step = MySteps.fourthScreen;
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
        ],
      );
    }
    return Column(
      children: [
        Lottie.asset('assets/uploadfiles.json'),
        const Center(
            child: Text('Currently publishing your book to our servers'))
      ],
    );
  }

  Widget bookFieldWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        textAlignVertical: TextAlignVertical.top,
        controller: _descriptionController,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 6,
        maxLength: 500,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Write a description',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              _descriptionController.clear();
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

  void addBookToList() {
    if (_booktradeController.text.isNotEmpty) {
      tradeBooks.add(_booktradeController.text.trim());
      _booktradeController.clear();
    }
    setState(() {});
  }

  String checkBoxes() {
    String res = 'alldone';
    if (_booknameController.text.isEmpty) {
      res = "Book name is empty";
    } else if (chosenGenre == 'Select book genre') {
      res = "Choose an genre";
    } else if (_descriptionController.text.isEmpty) {
      res = "Description is empty";
    } else if (_bookpriceController.text.isEmpty) {
      res = "Book price is empty";
    }
    if (res != 'alldone') {
      showSnackBar(res, context, true);
    }
    return res;
  }

  void publishBook() async {
    setState(() {
      uploading = true;
    });
    MyUser user = Provider.of<UserProvider>(context, listen: false).getUser;
    await FirestoreMethods().uploadBook(
      username: user.username,
      uid: user.uid,
      userimageUrl: user.photoUrl,
      userphonenumber: user.phonenumber,
      bookname: _booknameController.text.trim(),
      bookgenre: chosenGenre,
      description: _descriptionController.text.trim(),
      price: _bookpriceController.text.trim(),
      booksToTrade: tradeBooks,
      file: selectedImages,
    );
    setState(() {
      percent = 1.0;
      uploading = false;
    });
    await Future.delayed(
      const Duration(milliseconds: 1000),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
