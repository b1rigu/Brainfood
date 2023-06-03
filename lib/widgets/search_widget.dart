import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

Widget searchWidget(Function() ontap, String label) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              IconlyLight.search,
              color: Colors.black87,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
