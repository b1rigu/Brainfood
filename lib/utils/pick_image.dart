import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

pickImage(bool isProfile, bool gallery) async {
  final ImagePicker imagePicker = ImagePicker();
  if (isProfile) {
    XFile? file;
    if (gallery) {
      file = await imagePicker.pickImage(source: ImageSource.gallery);
    } else {
      file = await imagePicker.pickImage(source: ImageSource.camera);
    }
    if (file != null) {
      Uint8List image = await file.readAsBytes();
      Uint8List result = await FlutterImageCompress.compressWithList(
        image,
        quality: 20,
      );
      return result;
    }
  } else {
    List<Uint8List>? selectedImages = [];
    List<XFile>? images = await imagePicker.pickMultiImage();
    if (images != null) {
      for (int i = 0; i < images.length; i++) {
        Uint8List image = await images[i].readAsBytes();
        Uint8List result = await FlutterImageCompress.compressWithList(
          image,
          quality: 20,
        );
        selectedImages.add(result);
      }
      return selectedImages;
    }
  }
}
