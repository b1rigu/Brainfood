import 'package:brainfood/widgets/bouncing_button.dart';
import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String text;
  final Gradient? gradient;
  final Color? boxcolor;
  final Function() onPressed;
  final double toppadding;
  final double bottompadding;
  final double leftpadding;
  final double rightpadding;
  final Color textcolor;
  final String icon;
  final bool bouncingEnabled;

  const MyTextButton({
    Key? key,
    required this.text,
    this.gradient,
    required this.onPressed,
    this.boxcolor,
    this.toppadding = 16.0,
    this.bottompadding = 16.0,
    this.leftpadding = 16.0,
    this.rightpadding = 16.0,
    this.textcolor = Colors.white,
    this.icon = '',
    this.bouncingEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: toppadding,
        bottom: bottompadding,
        left: leftpadding,
        right: rightpadding,
      ),
      child: bouncingEnabled
          ? Bouncing(
              onPress: onPressed,
              child: buttonStyle(),
            )
          : GestureDetector(
              onTap: onPressed,
              child: buttonStyle(),
            ),
    );
  }

  Widget buttonStyle() {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: boxcolor,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        gradient: gradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon == ''
              ? const SizedBox.shrink()
              : Image.asset(
                  icon,
                  width: 25,
                  height: 25,
                ),
          icon == ''
              ? const SizedBox.shrink()
              : const SizedBox(
                  width: 10,
                ),
          Text(
            text,
            style: TextStyle(
              color: textcolor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
