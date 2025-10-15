import 'dart:ui';
import 'package:flutter/material.dart';

import '../utilities/color.dart';

commonDialog(BuildContext context, Widget widgett, double height) {
  return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var size = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: CColors.light.withOpacity(0.15),
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Center(child: widgett),
            ),
          ),
        );
      });
}
