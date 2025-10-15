import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../main.dart';

class ApiHelper {
  helper(BuildContext context, final response) {
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
  }
}
