import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/authentication/verification.dart';
import 'package:vms_mobile_app/provider/common_provider.dart';
import 'package:vms_mobile_app/screens/mobile/print_wifi.dart';
import '../decoration/buttons.dart';
import '../decoration/container.dart';
import '../decoration/dialogs.dart';
import '../main.dart';
import '../provider/layoutprovider.dart';
import '../utilities/color.dart';
import '../utilities/fonts.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: CColors.appbar,
            height: size.height,
            width: size.width / 2 + 50,
            child: Stack(
              children: [
                SizedBox(
                    height: size.height,
                    child: Column(children: [
                      const SizedBox(height: 50),
                      ListTile(
                        title: textSideBar("Attendance"),
                        leading: const Icon(
                          Icons.event_available,
                          color: CColors.light,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VerificationScreen(page: false),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        onTap: () {
                          Provider.of<LayoutProvider>(context, listen: false)
                              .changeNavBar(context, 0);
                          Navigator.of(context).pop();
                        },
                        title: textSideBar("Entry"),
                        leading: const Icon(Icons.transfer_within_a_station,
                            color: CColors.light),
                      ),
                      ListTile(
                          onTap: () {
                            Provider.of<LayoutProvider>(context, listen: false)
                                .changeNavBar(context, 1);
                            Navigator.of(context).pop();
                          },
                          title: textSideBar("Visitors"),
                          leading: const Icon(Icons.person_rounded,
                              color: CColors.light)),
                      ListTile(
                          onTap: () {
                            Provider.of<LayoutProvider>(context, listen: false)
                                .changeNavBar(context, 2);
                            Navigator.of(context).pop();
                          },
                          title: textSideBar("Unmatched"),
                          leading:
                              const Icon(Icons.pan_tool, color: CColors.light)),
                      ListTile(
                          title: textSideBar("History"),
                          onTap: () {
                            Provider.of<LayoutProvider>(context, listen: false)
                                .changeNavBar(context, 3);
                            Navigator.of(context).pop();
                          },
                          leading:
                              const Icon(Icons.history, color: CColors.light)),
                      ListTile(
                          title: textSideBar("Print"),
                          onTap: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //       builder: (BuildContext context) =>
                            //           const PrinterPage()))
                          },
                          leading:
                              const Icon(Icons.history, color: CColors.light)),
                      ListTile(
                          title: textSideBar("Print Wifi"),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const PrintWifi())),
                          leading:
                              const Icon(Icons.history, color: CColors.light)),
                      ListTile(
                          title: textSideBar("Logout"),
                          onTap: () =>
                              commonDialog(context, const LogoutDialog(), 100),
                          leading:
                              const Icon(Icons.logout, color: CColors.light)),
                    ])),
                Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                        radius: 14,
                        backgroundColor: CColors.brand1,
                        child: IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              indexKey.currentState!.openEndDrawer();
                            },
                            icon: const Icon(Icons.clear,
                                color: CColors.dark, size: 20))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: decorCard(),
        height: 180,
        width: MediaQuery.of(context).size.width - 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 12),
            textHeading("Logout"),
            const SizedBox(height: 8),
            textProfile("Sure you want to logout"),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              buttonDialogYes(
                  context,
                  "Logout",
                  () => Provider.of<CommonProvider>(context, listen: false)
                      .logOut(context)),
              const SizedBox(width: 8),
              buttonDialogNo(context, "Cancel"),
            ]),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
