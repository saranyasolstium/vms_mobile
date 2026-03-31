import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/common_provider.dart';
import '../utilities/notifications.dart';

class ApiHelper {
  static bool _isLoggingOut = false;

  dynamic helper(BuildContext context, dynamic response) {
    // 🔴 HANDLE 401 FIRST
    if (response.statusCode == 401) {
      _forceLogout(context);
      return null;
    }

    try {
      final message = jsonDecode(response.body);
      return message;
    } on SocketException {
      logger.wtf("socket exception --->");
    } on HttpException catch (e) {
      logger.wtf("HTTP exception--->$e");
    } on FormatException catch (e) {
      logger.wtf("format exception--->$e");
    }
    return null;
  }

  void _forceLogout(BuildContext context) {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // 🔐 Clear session (if you store token)
        // encryptedSharedPreferences.clear();

        // 🚪 Direct logout (no dialog)
        Provider.of<CommonProvider>(context, listen: false).logOut(context);
        notif(context, 'Failed', "Session expired. Please login again.");
      } catch (e) {
        logger.wtf("Force logout error: $e");
      } finally {
        Future.delayed(const Duration(seconds: 1), () {
          _isLoggingOut = false;
        });
      }
    });
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';

// import '../main.dart';

// class ApiHelper {
//   helper(BuildContext context, final response) {
//     try {
//       final message = jsonDecode(response.body);
//       return message;
//     } on SocketException {
//       logger.wtf("socket exception --->");
//     } on HttpException catch (e) {
//       logger.wtf("HTTP exception--->$e");
//     } on FormatException catch (e) {
//       logger.wtf("format exception--->$e");
//     }
//   }
// }
