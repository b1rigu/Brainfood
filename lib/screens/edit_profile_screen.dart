import 'dart:typed_data';

import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/providers/user_provider.dart';
import 'package:brainfood/utils/auth_methods.dart';
import 'package:brainfood/utils/pick_image.dart';
import 'package:brainfood/utils/show_snackbar.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? im;
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
                im = await pickImage(true, true);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (_image != null && im == null) {
      //nothing
    } else {
      setState(() {
        _image = im;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).getUser;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 16,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.07,
              ),
              selectprofilepic(user),
              SizedBox(
                height: height * 0.07,
              ),
              MyTextField(
                keyboardType: TextInputType.text,
                labelText: 'Username',
                hintText: user.username,
                controller: _usernameController,
                onpressX: () {
                  _usernameController.clear();
                },
              ),
              SizedBox(
                height: height * 0.03,
              ),
              MyTextButton(
                text: 'Save profile',
                onPressed: () {
                  saveUserProfile(user);
                },
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(149, 117, 205, 1),
                    Color.fromRGBO(247, 86, 114, 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectprofilepic(MyUser user) {
    return Center(
      child: Stack(
        children: [
          _image != null
              ? CircleAvatar(
                  radius: 100,
                  backgroundImage: MemoryImage(_image!),
                )
              : CircleAvatar(
                  radius: 100,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
          Positioned(
            bottom: -6,
            left: 150,
            child: IconButton(
              onPressed: selectImage,
              icon: const Icon(
                IconlyLight.edit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveUserProfile(MyUser user) async {
    setState(() {
      _isLoading = true;
    });
    String res = await FirebaseAuthMethods().editProfile(
        uid: user.uid, username: _usernameController.text.trim(), file: _image);
    if (!mounted) return;
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      if (!mounted) return;
      showSnackBar(res, context, true);
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
}
