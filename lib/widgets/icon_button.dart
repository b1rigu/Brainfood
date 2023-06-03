import 'package:flutter/material.dart';

class IconnButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double right;
  final Function() onPressed;

  const IconnButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    required this.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5, right: right),
      child: IconButton(
        icon: Icon(icon),
        iconSize: iconSize,
        onPressed: onPressed,
      ),
    );
  }
}
