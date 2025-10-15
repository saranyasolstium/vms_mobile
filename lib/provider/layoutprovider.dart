import 'package:flutter/cupertino.dart';

class LayoutProvider extends ChangeNotifier {
  int navbarState = 0;

  changeNavBar(BuildContext context, int numb) {
    navbarState = numb;
    return notifyListeners();
  }
}
