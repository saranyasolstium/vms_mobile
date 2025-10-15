import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/provider/barcode_provider.dart';
import 'package:vms_mobile_app/provider/black_list_provider.dart';

import 'authentication/splash_screen.dart';
import 'provider/auth_provider.dart';
import 'provider/common_provider.dart';
import 'provider/layoutprovider.dart';
import 'provider/unitprovider.dart';

GlobalKey<ScaffoldState> indexKey = GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldState> mainKeyy = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

var logger = Logger();
void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<CommonProvider>(
          create: (context) => CommonProvider()),
      ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
      ChangeNotifierProvider<LayoutProvider>(
          create: (context) => LayoutProvider()),
      ChangeNotifierProvider<UnitProvider>(create: (context) => UnitProvider()),
      ChangeNotifierProvider<BarcodeProvider>(
          create: (context) => BarcodeProvider()),
      ChangeNotifierProvider<BlackListProvider>(
          create: (context) => BlackListProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
          scaffoldMessengerKey: snackbarKey,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen()),
    );
  }
}
