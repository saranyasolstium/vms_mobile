import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/authentication/location_select.dart';
import '../provider/auth_provider.dart';
import '../screens/mobile/main_screen.dart';
import '../service/shared_preferences.dart';
import '../utilities/color.dart';
import '../utilities/localvariable.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkData() async {
    await encryptedSharedPreferences
        .getString(LocVar.data)
        .then((String value) {
      if (value == "") {
        SharedStoreUtils.clearValue(LocVar.data);
        return Future.delayed(const Duration(milliseconds: 1000), () {
          return Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const LoginScreen()),
              (route) => false);
        });
      } else {
        Provider.of<AuthProvider>(context, listen: false)
            .convertUserData(context);
        return Future.delayed(const Duration(milliseconds: 1500), () {
          return Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const SelectLocation()),
              (route) => false);
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => checkData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.dark,
      body: Center(
        child: SizedBox(
          height: 100,
          child: Image.asset("assets/images/logo.png"),
        ),
      ),
    );
  }
}
