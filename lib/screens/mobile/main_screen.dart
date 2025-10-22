import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/dialogs.dart';
import 'package:vms_mobile_app/provider/auth_provider.dart';
import 'package:vms_mobile_app/screens/mobile/black_list/block_list.dart';
import 'package:vms_mobile_app/screens/mobile/history/history.dart';
import 'package:vms_mobile_app/utilities/localvariable.dart';
import 'package:vms_mobile_app/utilities/notifications.dart';
import '../../authentication/splash_screen.dart';
import '../../decoration/buttons.dart';
import '../../decoration/container.dart';
import '../../main.dart';
import '../../provider/layoutprovider.dart';
import '../../utilities/color.dart';
import '../../utilities/fonts.dart';
import '../../widgets/appbar.dart';
import '../../widgets/bottombar.dart';
import '../../widgets/sidebar.dart';
import 'entry_screen.dart';
import 'unmatched.dart';
import 'exit/visitors_screen.dart';

final EncryptedSharedPreferences encryptedSharedPreferences =
    EncryptedSharedPreferences();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _eventFormKey = GlobalKey<FormState>();

  void log(String text) {
    logger.d("LOG: $text");
  }

  // void onConnectPressed() async {
  //   try {
  //     await pusher.init(
  //       apiKey: LocVar.apiKey,
  //       cluster: LocVar.cluster,
  //       onConnectionStateChange: onConnectionStateChange,
  //       onError: onError,
  //       onSubscriptionSucceeded: onSubscriptionSucceeded,
  //       onEvent: onEvent,
  //       onSubscriptionError: onSubscriptionError,
  //       onDecryptionFailure: onDecryptionFailure,
  //       onMemberAdded: onMemberAdded,
  //       onMemberRemoved: onMemberRemoved,
  //       // authEndpoint: "<Your Authendpoint Url>",
  //       // onAuthorizer: onAuthorizer
  //     );
  //   } catch (e) {
  //     log("ERROR: $e");
  //   }
  // }

  pusherCheck(Map map) {
    int id = Provider.of<AuthProvider>(context, listen: false).id;
    if (id == map['user_id']) {
    } else {
      return;
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  // void onEvent(PusherEvent event) {
  //   log("onEvent: $event");
  //   int id = Provider.of<AuthProvider>(context, listen: false).id;
  //   Map data = jsonDecode(event.data);
  //   if (id == data['message']['user_id']) {
  //     notif('Success', data['message']['message']);
  //     encryptedSharedPreferences.clear();
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //             builder: (BuildContext context) => const SplashScreen()),
  //         (route) => false);
  //   } else {
  //     return;
  //   }
  // }

  // void onSubscriptionSucceeded(String channelName, dynamic data) {
  //   log("onSubscriptionSucceeded: $channelName data: $data");
  //   final me = pusher.getChannel(channelName)?.me;
  //   log("Me: $me");
  // }

  // void onSubscriptionError(String message, dynamic e) {
  //   log("onSubscriptionError: $message Exception: $e");
  // }

  // void onDecryptionFailure(String event, String reason) {
  //   log("onDecryptionFailure: $event reason: $reason");
  // }

  // void onMemberAdded(String channelName, PusherMember member) {
  //   log("onMemberAdded: $channelName user: $member");
  // }

  // void onMemberRemoved(String channelName, PusherMember member) {
  //   log("onMemberRemoved: $channelName user: $member");
  // }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {
      "auth": "foo:bar",
      "channel_data": '{"user_id": 1}',
      "shared_secret": "foobar"
    };
  }

  // void onTriggerEventPressed() async {
  //   var eventFormValidated = _eventFormKey.currentState!.validate();
  //   if (!eventFormValidated) {
  //     return;
  //   }
  //   pusher.trigger(PusherEvent(
  //       channelName: 'my-channel',
  //       eventName: 'my-event',
  //       data: 'order-received'));
  // }

  List<Widget> widgets = [
    const EntryScreen(),
    const VisitorScreen(),
    const BlockList(),
    const HistoryScreen(),
    const UnMatchedScreen(),
  ];
  @override
  void initState() {
    super.initState();
    // onConnectPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: indexKey,
        drawer: const SideBar(),
        bottomNavigationBar: bottomNavigationBar(context),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0), child: customAppBar()),
        backgroundColor: CColors.dark,
        body: WillPopScope(
          onWillPop: () async {
            return commonDialog(context, const ExitDialog(), 300);
          },
          child: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(child: Consumer<LayoutProvider>(
                    builder: (_, provd, __) {
                      return widgets[provd.navbarState];
                    },
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExitDialog extends StatefulWidget {
  const ExitDialog({Key? key}) : super(key: key);

  @override
  State<ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
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
            textHeading("QUIT"),
            const SizedBox(height: 8),
            textProfile("Sure you want to exit?"),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              buttonDialogYes(context, "Exit", () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }),
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
