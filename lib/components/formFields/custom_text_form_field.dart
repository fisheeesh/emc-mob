import 'package:emotion_check_in_app/utils/constants/colors.dart';
import 'package:emotion_check_in_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: EColors.grey,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: EColors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ESizes.roundedXs),
          borderSide: BorderSide(color: EColors.grey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ESizes.roundedXs),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
