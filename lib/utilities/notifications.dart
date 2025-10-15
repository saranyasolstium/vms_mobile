import 'package:flutter/material.dart';
import 'package:get/get.dart';

notif(String head, String desc) => Get.snackbar(head, desc,
    margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
    duration: const Duration(seconds: 2),
    dismissDirection: DismissDirection.horizontal,
    animationDuration: const Duration(milliseconds: 600));
