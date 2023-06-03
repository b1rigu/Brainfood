import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //adding image to firebase storage
  Future<List<String>> uploadImageToStorage(
    String childName,
    List<Uint8List>? files,
    bool isPost,
  ) async {
    List<String> list = [];
    String id = '';
    List<String> downloadUrls = [];
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (files == null) {
      //files null
    } else {
      if (isPost) {
        id = const Uuid().v1();
        ref = ref.child(id);
        for (int i = 0; i < files.length; i++) {
          UploadTask uploadTask = ref.child(i.toString()).putData(files[i]);
          TaskSnapshot snap = await uploadTask;
          String downloadUrl = await snap.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        }
      } else {
        UploadTask uploadTask = ref.putData(files[0]);
        TaskSnapshot snap = await uploadTask;
        String downloadUrl = await snap.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    }

    list.add(id);
    list.addAll(downloadUrls);
    return list;
  }

  Future<void> deleteImagefromStorage(
    String childName,
    String postId,
    bool isPost,
    int pictureCount,
  ) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      ref = ref.child(postId);
      for (int i = 0; i < pictureCount; i++) {
        await ref.child(i.toString()).delete();
      }
    } else {
      await ref.delete();
    }
  }
}
