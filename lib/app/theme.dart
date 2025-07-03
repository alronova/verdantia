import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Poppins for general UI
  static final poppinsBody = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final poppinsTitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Press Start 2P for personality/chat/plant names
  static final retroPixel = GoogleFonts.pressStart2p(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final retroPixelSmall = GoogleFonts.pressStart2p(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}
