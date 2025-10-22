import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/authentication/verification.dart';
import 'package:vms_mobile_app/provider/common_provider.dart';
import '../screens/mobile/main_screen.dart';
import '../service/api_service.dart';
import '../utilities/localvariable.dart';
import '../utilities/notifications.dart';

class AuthProvider extends ChangeNotifier {
  bool authLoading = false;
  int id = 0;
  String name = "";
  String token = "";
  String role = "";
  int visitors = 0;
  int users = 0;
  int roles = 0;
  String latitude = "";
  String longitude = "";

  loginSetup(BuildContext context, var data) {
    print(data);
    token = data['token'];
    id = data['user']['user_id'];
    name = data['user']['username'];
    role = data['role'];
    visitors = data['permission']['visitors'];
    users = data['permission']['users'];
    roles = data['permission']['roles'];
    Provider.of<CommonProvider>(context, listen: false)
        .setLocation(data['location']);
    notifyListeners();
  }

  convertUserData(BuildContext context) async {
    await encryptedSharedPreferences
        .getString(LocVar.data)
        .then((String value) {
      return loginSetup(context, jsonDecode(value));
    });
  }

  authLoadingOn() {
    authLoading = true;
    notifyListeners();
  }

  authLoadingOff() {
    authLoading = false;
    notifyListeners();
  }

  login(BuildContext context, String username, String password,
      String selectedLocation) {
    if (password.isEmpty || username.isEmpty) {
      return notif('Failed', "Kindly enter the credentials.");
    }
    FocusScope.of(context).unfocus();
    // if (selectedLocation == "null") {
    //   return failMessage("Kindly select any location.");
    // }
    authLoadingOn();
    ApiService().post2(context, "login",
        params: {"username": username, "password": password}).then((val) {
      authLoadingOff();
      if (val != null) {
        if (val['status'] == "error") {
          notif('Failed', val['message']);
        } else {
          loginSetup(context, val['data']);
          // SharedStoreUtils.setValue(LocVar.data, jsonEncode(val['data']).toString());
          encryptedSharedPreferences.setString(
              LocVar.data, jsonEncode(val['data']).toString());
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  const VerificationScreen(page: false)));
        }
      } else {
        return;
      }
    });
  }
}
