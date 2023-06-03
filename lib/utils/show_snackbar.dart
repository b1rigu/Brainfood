import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

showSnackBar(String content, BuildContext context, bool error) {
  if (error) {
    MotionToast.error(
      description: Text(content),
      animationDuration: const Duration(milliseconds: 500),
      height: 60,
    ).show(context);
  } else {
    MotionToast.success(
      description: Text(content),
      animationDuration: const Duration(milliseconds: 500),
      height: 60,
    ).show(context);
  }
}
