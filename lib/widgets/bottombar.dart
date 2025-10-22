import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/provider/layoutprovider.dart';
import 'package:vms_mobile_app/utilities/color.dart';
import 'package:vms_mobile_app/utilities/fonts.dart';

bottomNavigationBar(BuildContext context) => ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: const BoxDecoration(
              color: CColors.appbar,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Consumer<LayoutProvider>(
            builder: (_, provd, __) {
              return GNav(
                gap: 12,
                // tabMargin: const EdgeInsets.symmetric(vertical: 4),
                activeColor: CColors.dark,
                // tabActiveBorder: Border.none(width: 1.5, color: CColors.success),
                // iconSize: 32,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: CColors.brand1,
                tabs: const [
                  GButton(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      icon: Icons.arrow_circle_down,
                      iconSize: 28,
                      iconColor: CColors.brand1,
                      text: 'Entry',
                      textStyle: FFonts.gnav),
                  GButton(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      icon: Icons.account_circle_rounded,
                      iconSize: 28,
                      iconColor: CColors.brand1,
                      text: 'Visitor',
                      textStyle: FFonts.gnav),
                  GButton(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      icon: Icons.block,
                      iconSize: 28,
                      iconColor: CColors.brand1,
                      text: 'Black List',
                      textStyle: FFonts.gnav),
                  GButton(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      icon: Icons.history,
                      iconSize: 28,
                      iconColor: CColors.brand1,
                      text: 'History',
                      textStyle: FFonts.gnav),
                  GButton(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      icon: Icons.access_alarm,
                      iconSize: 28,
                      iconColor: CColors.brand1,
                      text: 'Unmatched',
                      textStyle: FFonts.gnav),
                ],
                selectedIndex: provd.navbarState,
                onTabChange: (index) {
                  Provider.of<LayoutProvider>(context, listen: false)
                      .changeNavBar(context, index);
                },
              );
            },
          ),
        ),
      ),
    );
