import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/main.dart';
import 'package:vms_mobile_app/screens/feeds.dart';
import 'package:vms_mobile_app/utilities/color.dart';
import 'package:vms_mobile_app/utilities/fonts.dart';

import '../authentication/location_dialog.dart';
import '../decoration/dialogs.dart';
import '../provider/common_provider.dart';

customAppBar() => Container(
    height: 60,
    margin: const EdgeInsets.all(2),
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
    decoration: const BoxDecoration(
        color: CColors.appbar,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          GestureDetector(
            onTap: () => indexKey.currentState!.openDrawer(),
            child: SizedBox(
                height: 48,
                width: 48,
                child: Image.asset("assets/images/hamburger.png",
                    fit: BoxFit.fill)),
          ),
          Consumer<CommonProvider>(builder: (_, provider, __) {
            return Row(
              children: [
                textBlue(provider.locations[provider.selectedLocation]
                    ['location_name']),
              ],
            );
          }),
        ],
      ),
      Row(
        children: [
          IconButton(
              onPressed: () => commonDialog(
                  indexKey.currentContext!, const LocationDialog(), 350),
              icon:
                  const Icon(Icons.settings, size: 32, color: CColors.brand1)),
          SizedBox(
            height: 45,
            child: ElevatedButton(
                onPressed: () {
                  Provider.of<CommonProvider>(indexKey.currentContext!,
                          listen: false)
                      .getEntryFeed();
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: indexKey.currentContext!,
                      builder: (context) => const FeedList());
                },
                style: TextButton.styleFrom(
                    backgroundColor: CColors.brand1,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Row(
                  children: [
                    const Icon(Icons.shortcut),
                    const SizedBox(width: 8),
                    textButton("Feed")
                  ],
                )),
          )
        ],
      ),
    ]));
