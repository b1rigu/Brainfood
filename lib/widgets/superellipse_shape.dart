import 'package:flutter/material.dart';

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(size.width * 0.1000000, size.height * 0.1032325);
    path0.cubicTo(
        size.width * -0.0032500,
        size.height * 0.2090719,
        size.width * 0.0005000,
        size.height * 0.7825860,
        size.width * 0.0990000,
        size.height * 0.8873827);
    path0.cubicTo(
        size.width * 0.1995000,
        size.height * 0.9903545,
        size.width * 0.7992500,
        size.height * 0.9916580,
        size.width * 0.9010000,
        size.height * 0.8873827);
    path0.cubicTo(
        size.width * 0.9997500,
        size.height * 0.7815433,
        size.width * 1.0010000,
        size.height * 0.2075078,
        size.width * 0.9010000,
        size.height * 0.1042753);
    path0.cubicTo(
        size.width * 0.8020000,
        size.height * -0.0015641,
        size.width * 0.1995000,
        size.height * -0.0002607,
        size.width * 0.1000000,
        size.height * 0.1032325);
    path0.close();
    return path0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
