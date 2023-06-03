import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MyTextField extends StatefulWidget {
  final double top;
  final double bottom;
  final double left;
  final double right;
  final TextInputType keyboardType;
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool ispass;
  final bool isNumber;
  final bool useFormatter;
  final int maxLength;
  final Function() onpressX;

  const MyTextField({
    Key? key,
    this.top = 0.0,
    this.bottom = 0.0,
    this.left = 16.0,
    this.right = 16.0,
    this.maxLength = 50,
    this.isNumber = false,
    this.useFormatter = true,
    required this.keyboardType,
    required this.labelText,
    this.hintText = '',
    required this.controller,
    this.ispass = false,
    required this.onpressX,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.top,
        bottom: widget.bottom,
        left: widget.left,
        right: widget.right,
      ),
      child: TextField(
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        obscureText: widget.ispass ? !isPassVisible : false,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          suffixIcon: widget.ispass
              ? IconButton(
                  splashRadius: 18.0,
                  onPressed: () =>
                      setState(() => isPassVisible = !isPassVisible),
                  icon: isPassVisible
                      ? const Icon(
                          Icons.visibility,
                          color: Color.fromRGBO(149, 117, 205, 1),
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: Color.fromRGBO(149, 117, 205, 1),
                        ),
                )
              : IconButton(
                  splashRadius: 18.0,
                  onPressed: widget.onpressX,
                  icon: const Icon(
                    Icons.close,
                    color: Color.fromRGBO(149, 117, 205, 1),
                  ),
                ),
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(149, 117, 205, 1)),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        inputFormatters: widget.useFormatter
            ? [
                widget.isNumber
                    ? NumericTextFormatter()
                    : FilteringTextInputFormatter.deny(
                        RegExp(r"\s\b|\b\s"),
                      ),
              ]
            : null,
      ),
    );
  }
}

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final f = NumberFormat("#,###");
      final number =
          int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
            offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}
