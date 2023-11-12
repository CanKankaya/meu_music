import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    required this.controller,
    required this.focus,
    this.hintText,
    this.inputType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focus;
  final String? hintText;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final IconButton? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextFormField(
        controller: controller,
        focusNode: focus,
        textInputAction: TextInputAction.done,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 29, 29, 29),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
