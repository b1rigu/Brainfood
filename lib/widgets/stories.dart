import 'package:brainfood/widgets/superellipse_shape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Stories extends StatelessWidget {
  const Stories({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            height: 69,
            width: 69,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(149, 117, 205, 1),
                  Color.fromARGB(255, 66, 158, 245),
                ],
              ),
            ),
          ),
          ClipPath(
            clipper: CustomClipPath(),
            child: SizedBox(
              height: 67,
              width: 67,
              child: Container(color: Colors.white),
            ),
          ),
          ClipPath(
            clipper: CustomClipPath(),
            child: SizedBox(
              height: 63,
              width: 63,
              child: CachedNetworkImage(
                imageUrl:
                    'https://img.xcitefun.net/users/2014/07/361484,xcitefun-nature-color-9.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
