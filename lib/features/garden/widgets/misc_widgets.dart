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

TextStyle pixelStyle =
    GoogleFonts.pixelifySans(fontSize: 15, color: Colors.black);

Widget newContainer({required Widget child, double padding = 8}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 238, 236, 208),
      borderRadius: BorderRadius.circular(padding),
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: child,
  );
}

Widget infoBox({required String text, required String info}) {
  return newContainer(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text(text), Text(info)],
      ),
    ),
  );
}
