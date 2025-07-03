import 'package:flutter/material.dart';

final ButtonStyle circularBtn = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFB9CBB3),
  foregroundColor: const Color(0xFF2C5E3B),
  elevation: 4,
  shadowColor: Colors.black26,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
);

InputDecoration inputDecor(String hintText, Icon icon) => InputDecoration(
      filled: true,
      suffixIcon: icon,
      fillColor: const Color(0xFFEFF3DC), // light green input background
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.black, // Black border color
          width: 1.0, // 1 pixel width
        ),
        borderRadius: BorderRadius.circular(24), // optional rounding
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    );
