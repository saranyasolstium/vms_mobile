import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color.dart';

class FFonts {
  static var message = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: CColors.dark,
      letterSpacing: 0.5);
  static var labelStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CColors.brand1,
      letterSpacing: 0.5);
  static var formFont = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CColors.light,
      letterSpacing: 0.5);
  static const gnav = TextStyle(
      fontSize: 16,
      color: CColors.dark,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 1);
}

Widget textHeading(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: CColors.light,
        letterSpacing: 0.05));
Widget textSideHeading(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: CColors.brand1,
        letterSpacing: 0.25));
Widget textButton(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: CColors.dark,
        letterSpacing: 0.25));
Widget text14(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CColors.dark,
        letterSpacing: 0.25));
Widget text18(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: CColors.light,
        letterSpacing: 0.75),
    textAlign: TextAlign.start);
Widget textNumber(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 50,
        fontWeight: FontWeight.w300,
        color: CColors.light,
        letterSpacing: 0.25));
Widget textDesc(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        color: CColors.light,
        letterSpacing: 1));
Widget textLink(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CColors.brand1,
        letterSpacing: 0.25));
Widget textLinkred(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CColors.danger,
        letterSpacing: 0.25));
Widget text10(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: CColors.light,
        letterSpacing: 0.25));
Widget textBold12(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: CColors.light,
        letterSpacing: 0.25));
Widget textYellow(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        color: Colors.amber,
        letterSpacing: 1));
Widget textGreen(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w200,
        color: Colors.green,
        letterSpacing: 1));
Widget textGreenBold(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.green,
        letterSpacing: 1));
Widget textBlue(String sample) => Text(sample,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: CColors.brand1,
        letterSpacing: 0.25));
Widget textBlue24(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: CColors.brand1,
        letterSpacing: 0.25));
Widget textRed(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: const Color(0xffEE5151),
        letterSpacing: 0.25));
Widget textGrey(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
        letterSpacing: 0.25));
Widget textSideBar(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: CColors.light,
        letterSpacing: 0.5));
Widget textProfile(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: CColors.light,
        letterSpacing: 0.5));
Widget message(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w200,
        color: CColors.light,
        letterSpacing: 1));
Widget textShade(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: CColors.shade2,
        letterSpacing: 0.25));
Widget textContent(String sample) => Text(sample,
    style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: CColors.light,
        letterSpacing: 0.25));
