import 'package:flutter/material.dart';

import '../utilities/color.dart';
import '../utilities/fonts.dart';

Widget buttonPrimary(String name, VoidCallback funct) => SizedBox(
      height: 50,
      width: double.maxFinite,
      child: ElevatedButton(
          style: TextButton.styleFrom(
              backgroundColor: CColors.brand1,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: funct,
          child: textButton(name)),
    );
Widget buttonWidth(String name, VoidCallback funct, double width) => SizedBox(
      height: 48,
      width: width,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: CColors.brand1,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: funct,
        child: textButton(name),
      ),
    );
Widget buttonAddnew(String name, VoidCallback funct) => SizedBox(
      height: 50,
      width: 250,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: CColors.brand1,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: funct,
        child: textButton(name),
      ),
    );
Widget buttonSecondaryOutline(String name, VoidCallback funct) => SizedBox(
      height: 50,
      width: double.maxFinite,
      child: ElevatedButton(
        style: TextButton.styleFrom(
          side: const BorderSide(width: 1, color: CColors.danger),
          backgroundColor: CColors.dark,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: funct,
        child: textLinkred(name),
      ),
    );

Widget buttonClose(String name, VoidCallback funct) => SizedBox(
      height: 50,
      width: double.maxFinite,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1.5, color: Color(0xffEE5151)),
              borderRadius: BorderRadius.circular(12),
            )),
        onPressed: funct,
        child: textRed(name),
      ),
    );
Widget buttonDialogYes(BuildContext context, String name, VoidCallback funct) =>
    SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width / 2 - 30,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: CColors.brand1,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        onPressed: funct,
        child: textButton(name),
      ),
    );

Widget buttonDialogNo(BuildContext context, String name) => SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width / 2 - 30,
      child: ElevatedButton(
        style: TextButton.styleFrom(
            backgroundColor: CColors.light,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        onPressed: () => Navigator.pop(context),
        child: textButton(name),
      ),
    );
