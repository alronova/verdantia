import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

actionButton(String text, VoidCallback onTap) => ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffF3EFB1),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(width: 1, color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      label: Text(
        text,
        style: GoogleFonts.pixelifySans(fontSize: 15),
      ),
    );

TextStyle pixelStyle = GoogleFonts.pixelifySans();
