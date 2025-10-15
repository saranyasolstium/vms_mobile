import 'package:flutter/material.dart';

import '../../../decoration/container.dart';
import '../../../decoration/text_fields.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';

TextEditingController searchcontrol = TextEditingController();

searchAllScreen(BuildContext context) => SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width / 1.9,
            child: searchField("Search here..", searchcontrol),
          ),
          Container(
            height: 45,
            decoration: decorFilled(),
            width: MediaQuery.of(context).size.width / 3,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              textLink("14.02.2022"),
              const Icon(
                Icons.arrow_drop_down,
                color: CColors.brand1,
              ),
            ]),
          ),
        ],
      ),
    );

searchAllScreenWeb(BuildContext context) => SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 36),
          Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 22, right: 24, top: 26),
              child: SizedBox(height: 70, width: 644, child: searchFieldWeb(context, "Search here..", searchcontrol))),
          const SizedBox(width: 19.5),
          Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 24, right: 24, top: 24),
              child: Container(
                  height: 45,
                  decoration: decorFilled(),
                  width: 159,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [textLink("14.02.2022"), const Icon(Icons.arrow_drop_down, color: CColors.brand1)]))),
          SizedBox(
            width: MediaQuery.of(context).size.width / 8,
          ),
          SizedBox(
            height: 55,
            width: 200,
            child: Row(
              children: [
                const Column(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: CColors.primary,
                      backgroundImage: AssetImage('assets/images/photo.png'),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textSideBar("Admin"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textSideHeading("Sounak"),
                        const SizedBox(width: 10),
                        Image.asset(
                          "assets/images/dropdown.png",
                          fit: BoxFit.cover,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
