import 'package:flutter/material.dart';

void notif(BuildContext context, String title, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.clearSnackBars();

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        "$title: $message",
        style: const TextStyle(color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,

      // 🔥 THIS is the key part
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 12,
        right: 12,
      ),

      backgroundColor: Colors.black87,
      duration: const Duration(seconds: 2),
    ),
  );
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// notif(String head, String desc) => Get.snackbar(head, desc,
//     margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
//     duration: const Duration(seconds: 2),
//     dismissDirection: DismissDirection.horizontal,
//     animationDuration: const Duration(milliseconds: 600));
