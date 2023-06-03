import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class ImageViewWidget extends StatelessWidget {
  final String imageUrl;
  final aspectRatio;
  double height;
  final double width;

  ImageViewWidget({
    Key? key,
    required this.imageUrl,
    required this.aspectRatio,
    this.height = 0,
    required this.width,
  }) : super(key: key);

  void getHeight() {
    height = (width - 16) / aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    getHeight();
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ZoomOverlay(
        animationDuration: const Duration(milliseconds: 200),
        animationCurve: Curves.easeInOut,
        minScale: 1.0,
        maxScale: 4.0,
        twoTouchOnly: true,
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: height,
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
