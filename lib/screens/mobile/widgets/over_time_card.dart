import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../decoration/buttons.dart';
import '../../../decoration/container.dart';
import '../../../provider/layoutprovider.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';
import 'image_box.dart';

class OverTimeCard extends StatefulWidget {
  const OverTimeCard({Key? key}) : super(key: key);

  @override
  State<OverTimeCard> createState() => _OverTimeCardState();
}

class _OverTimeCardState extends State<OverTimeCard> {
  bool check = true;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: CColors.shade1, borderRadius: BorderRadius.all(Radius.circular(12))),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 82, right: 16, left: 16, bottom: 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Provider.of<LayoutProvider>(context, listen: false).changeNavBar(context, 1),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 14, backgroundColor: CColors.brand1, child: Icon(Icons.arrow_back_rounded, color: CColors.light, size: 14)),
                    const SizedBox(width: 8),
                    textBlue("Back")
                  ],
                ),
              ),
              const CircleAvatar(radius: 16, backgroundColor: CColors.brand1, child: Icon(Icons.edit, color: CColors.light, size: 14))
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [const Icon(Icons.account_circle, color: CColors.light, size: 26), const SizedBox(width: 8), textButton("Dale Philip")],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [textDesc("In-Time: 21.01.2022 | 02:15"), textYellow("*Exit Gate")],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [textDesc("Out-Time: 21.01.2022 | 02:15"), textGreen("*30 Min")],
          ),
          const SizedBox(height: 12),
          textDesc("Mobile No: +65 1234 5678"),
          const SizedBox(height: 12),
          textDesc("Email ID: dalephilip@gmail.com"),
          contShade2(
              context, 150,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textDesc("Vechicle Image"),
                  const SizedBox(height: 12),
                  vechicleImage(),
                ],
              )),
          const SizedBox(height: 12),
          textDesc("Vehicle: KL 65 H 4383"),
          const SizedBox(height: 12),
          textDesc("Purpose: Delivery"),
          const SizedBox(height: 12),
          textDesc("Persons: 1"),
          const SizedBox(height: 12),
          check
              ? buttonPrimary(
                  "Out",
                  () => setState(() {
                        check = false;
                      }))
              : Column(
                  children: [
                    success ? const SizedBox() : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [textDesc("Are you sure he is out?"), textDesc("21.01.2022 | 02:41")],
                    ),
                    SizedBox(height: success ? 0 : 12),
                    success ? Image.asset("assets/images/success.png")
                        : buttonPrimary(
                        "Yes",
                          () => setState(() {
                            success = true;
                          })),
                    success ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [textDesc("Out Confirmed at?"), textDesc("21.01.2022 | 02:41")],
                      ),
                    ) : const SizedBox(),
                    const SizedBox(height: 12),
                    buttonClose(
                        "Close",
                            () => Provider.of<LayoutProvider>(context, listen: false).changeNavBar(context, 1))
                  ],
                ),
        ]),
      ),
    );
  }
}
