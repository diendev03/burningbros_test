import 'package:flutter/material.dart';

InputBorder inputBorder(Color borderColor) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: borderColor, width: borderColor == Colors.teal ? 1 : 0.5),
  );
}
