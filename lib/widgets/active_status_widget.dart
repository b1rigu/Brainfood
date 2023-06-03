import 'package:flutter/material.dart';

class ActiveStatusWidget extends StatefulWidget {
  final double radius;
  final bool active;
  const ActiveStatusWidget(
      {Key? key, required this.radius, required this.active})
      : super(key: key);

  @override
  State<ActiveStatusWidget> createState() => _ActiveStatusWidgetState();
}

class _ActiveStatusWidgetState extends State<ActiveStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.radius,
      width: widget.radius,
      decoration: BoxDecoration(
        color: widget.active ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(60),
      ),
    );
  }
}
