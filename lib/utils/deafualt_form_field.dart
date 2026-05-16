import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'const_values.dart';

class DefaultForm extends StatelessWidget {
  const DefaultForm({
    super.key,
    required this.title,
    required this.controller,
    this.validation,
    this.numberOfLines = 1,
    this.onChanged,
    this.icon,
    this.isPassword = false,
    this.suffixIcon,
    this.inputType = TextInputType.text,
  });

  final String title;
  final int numberOfLines;
  final TextEditingController controller;
  final String? Function(String?)? validation;
  final void Function(String)? onChanged;
  final IconData? icon;
  final bool isPassword;
  final Widget? suffixIcon;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: numberOfLines > 1 ? TextInputType.multiline : inputType,
      maxLines: numberOfLines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF222222), size: 20) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        errorStyle: TextStyle(color: Colors.red.shade300),
      ),
      validator: validation,
      onChanged: onChanged,
    );
  }
}
