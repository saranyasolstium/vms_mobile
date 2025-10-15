import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/utilities/notifications.dart';

import '../main.dart';
import '../service/api_service.dart';
import 'common_provider.dart';

class BlackListProvider extends ChangeNotifier {
  bool blackListLoading = false;
  String locationId = "";
  List blackList = [];

  getLocation() {
    locationId =
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
                .locations[
            Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
                .selectedLocation]['location_id'];
    blackListLoading = true;
    notifyListeners();
  }

  userLoadingOff() {
    blackListLoading = false;
    notifyListeners();
  }

  getBlockList() async {
    await getLocation();
    ApiService()
        .get(indexKey.currentContext!, "block_list/$locationId")
        .then((received) {
      userLoadingOff();
      if (received != null) {
        if (received['status'] == "success") {
          blackList = received['data'];
          print("saranya");
          print(blackList);
          notifyListeners();
        } else {
          blackList = [];
          notifyListeners();
          return;
        }
      }
      return;
    });
  }

  addBlackList(
      BuildContext context, String vehicle, String type, String reason) async {
    await getLocation();
    final keyName = type == "mobile" ? "mobile_no" : "vehicle_no";

    var data = {
      keyName: vehicle,
      "location": locationId,
      "block_reason": reason
    };
    print(data);
    ApiService()
        .post(indexKey.currentContext!, "store_block", params: data)
        .then((received) {
      userLoadingOff();
      print(received);
      if (received != null) {
        getBlockList();
        Navigator.of(context).pop();
        return notif("Success", received["message"]);
      } else {
        notif("Failed", received["message"]);
        return;
      }
    });
  }

  deleteBlackList(BuildContext context, String id) async {
    await getLocation();
    ApiService()
        .get(indexKey.currentContext!, "delete_block/$id")
        .then((received) {
      userLoadingOff();
      if (received != null) {
        getBlockList();
        Navigator.of(context).pop();
        return notif("Success", received["message"]);
      } else {
        return notif("Failed", received["message"]);
      }
    });
  }

  editBlackList(String id, String vehicle, String type, String reason,
      BuildContext context) async {
    await getLocation();
    final keyName = type == "mobile" ? "mobile_no" : "vehicle_no";

    var data = {
      keyName: vehicle,
      "location": Provider.of<CommonProvider>(indexKey.currentContext!,
                  listen: false)
              .locations[
          Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
              .selectedLocation]['location_id'],
      "id": id,
      "block_reason": reason
    };
    ApiService()
        .post(indexKey.currentContext!, "edit_block/$id", params: data)
        .then((received) {
      userLoadingOff();
      if (received != null) {
        getBlockList();
        Navigator.of(context).pop();
        return notif("Success", received["message"]);
      } else {
        notif("Failed", received["message"]);

        return;
      }
    });
  }

  searchBlockList(String search) async {
    if (search.length <= 1) {
      getBlockList();
    }
    await getLocation();
    ApiService()
        .get(indexKey.currentContext!, "search_block/$locationId/$search")
        .then((received) {
      userLoadingOff();
      if (received != null) {
        if (received['status'] == "success") {
          blackList = received['data']['data'];
          notifyListeners();
        } else {
          blackList = [];
          notifyListeners();
          return;
        }
      }
      return;
    });
  }
}
