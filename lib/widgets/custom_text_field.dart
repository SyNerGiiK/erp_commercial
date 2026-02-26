import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? icon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Widget? suffixIcon;
  final bool isPassword;
  final Key? fieldKey;
  final TextStyle? style;
  final String? hint;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.suffixIcon,
    this.isPassword = false,
    this.fieldKey,
    this.style,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      obscureText: isPassword,
      style: style ??
          TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly
            ? Colors.grey.shade100
            : Colors.white.withValues(alpha: 0.95),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppTheme.textLight),
      ),
    );
  }
}
