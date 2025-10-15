import 'package:flutter/material.dart';

import '../../decoration/text_fields.dart';
import '../../main.dart';
import '../../utilities/color.dart';
import '../../utilities/fonts.dart';

class Attendence extends StatefulWidget {
  const Attendence({Key? key}) : super(key: key);

  @override
  State<Attendence> createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
  @override
  Widget build(BuildContext context) {
    TextEditingController attendencecontrol = TextEditingController();
    return Scaffold(
      backgroundColor: CColors.dark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 60,
              color: CColors.appbar,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Image.asset(
                      "assets/images/back_btn.png",
                      scale: 0.7,
                    ),
                  ),
                ),
                textHeading("Attendence"),
              ]),
            ),
            attendanceField("Search here..", attendencecontrol)
          ],
        ),
      ),
    );
  }

  backBtnAppBar() => Container(
        height: 60,
        color: CColors.appbar,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => indexKey.currentState!.openDrawer(),
            child: SizedBox(height: 60, width: 60, child: Image.asset("assets/images/back_btn.png")),
          ),
        ]),
      );
}
