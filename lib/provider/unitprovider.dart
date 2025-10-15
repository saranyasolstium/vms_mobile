import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../service/api_service.dart';
import 'common_provider.dart';

class UnitProvider extends ChangeNotifier {
  bool unitLoading = false;
  String locationId = "";
  List unitList = [];

  getLocation() {
    locationId = Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .locations[Provider.of<CommonProvider>(indexKey.currentContext!, listen: false).selectedLocation]['location_id'];
    unitLoading = true;
    notifyListeners();
  }

  unitLoadingOff() {
    unitLoading = false;
    notifyListeners();
  }

  clearUnitList() {
    unitList.clear();
    notifyListeners();
  }

  getUnitList(String search) async {
    if (search.isEmpty) {
      unitList.clear();
      notifyListeners();
      return;
    }
    await getLocation();
    var data = {'location_id': locationId, 'search_key': search};
    ApiService().get(indexKey.currentContext!, "view_unit", params: data).then((received) {
      unitLoadingOff();
      if (received != null) {
        if (received['status'] == "success") {
          unitList = received['data']['data'];
          notifyListeners();
        } else {
          unitList = [];
          notifyListeners();
          return;
        }
      }
      return;
    });
  }
}
