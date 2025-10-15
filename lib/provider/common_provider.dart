import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/provider/layoutprovider.dart';
import 'package:vms_mobile_app/utilities/localvariable.dart';

import '../authentication/splash_screen.dart';
import '../main.dart';
import '../screens/mobile/entry_screen.dart';
import '../screens/mobile/exit/visitors_screen.dart';
import '../screens/mobile/main_screen.dart';
import '../service/api_service.dart';
import '../utilities/notifications.dart';
import 'auth_provider.dart';

class CommonProvider extends ChangeNotifier {
  bool commonLoading = false;
  bool commonLoading2 = false;
  List locations = [];
  int selectedLocation = 0;
  String customUrl = LocVar.url;

  void logOut(BuildContext context) {
    customUrl = LocVar.url;
    notifyListeners();
    encryptedSharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen()),
        (route) => false);
  }

  void loadingOff() {
    commonLoading = false;
    return notifyListeners();
  }

  void loadingOn() {
    commonLoading = true;
    return notifyListeners();
  }

  void setLocation(List list) {
    locations = list;
    notifyListeners();
  }

  void setSelectedLocation(int selected, bool stat) {
    selectedLocation = selected;
    notifyListeners();
    if (stat) {
      getCameras();
    }
    if (locations[selected]["is_local"] == 1) {
      customUrl = locations[selected]["url"] ?? LocVar.url;
      notifyListeners();
    } else {
      customUrl = LocVar.url;
      notifyListeners();
    }
  }

  getLocations(BuildContext context) {
    loadingOn();
    ApiService().get(context, "view_location").then((received) {
      loadingOff();
      if (received != null) {
        locations = received['data'];
        notifyListeners();
      } else {
        locations = [];
        return;
      }
    });
  }

  List purpose = [];
  getPurpose() {
    ApiService().get(indexKey.currentContext!, "get_purpose").then((val) {
      print(val);
      if (val != null) {
        if (val['data'] != null) {
          print(val['data']);
          purpose = val['data'];
          return notifyListeners();
        }
        return;
      } else {
        return;
      }
    });
  }

  List feeds = [];

  getEntryFeed() {
    loadingOn();
    // successMessage(
    //     "${customUrl}get_entry_feeds/${locations[selectedLocation]['location_id']}");
    ApiService()
        .getAllUrl(indexKey.currentContext!,
            "${customUrl}get_entry_feeds/${locations[selectedLocation]['location_id']}")
        .then((val) {
      loadingOff();
      // commonDialog(
      //     indexKey.currentContext!,
      //     Center(
      //       child: text10(val.toString()),
      //     ),
      //     500);
      if (val != null) {
        if (val["status"] == "error") {
          feeds = [];
          return notifyListeners();
        } else {
          if (val['data'] != null) {
            feedIndex = 0;
            feeds = val['data']['data'] ?? [];
            nextFeedPage = val['data']['next_page_url'] ?? "";
            if (feeds[feedIndex]['license_plate_number'] == null) {
              vehicleNo.clear();
              return notifyListeners();
            } else {
              List<String> stringArray =
                  feeds[feedIndex]['license_plate_number'].split("/");
              vehicleNo.text = stringArray[0];
              getVehicleData(stringArray[0]);
              return notifyListeners();
            }
          }
          return;
        }
      } else {
        return;
      }
    });
  }

  String nextFeedPage = "";

  addEntryFeeds() {
    if (nextFeedPage != "0") {
      loadingOn();
      ApiService()
          .getAllUrl(indexKey.currentContext!, nextFeedPage)
          .then((val) {
        loadingOff();
        if (val != null) {
          if (val["status"] == "error") {
            feeds = [];
            return notifyListeners();
          } else {
            feeds.addAll(val['data']['data']);
            nextFeedPage = val['data']['next_page_url'] ?? "0";
            return notifyListeners();
          }
        } else {
          return;
        }
      });
    } else {
      return notif('Failed', "No more feeds to refresh!");
    }
  }

  getVehicleData(String vehicle) {
    var data = {
      "vehicle_no": vehicle,
      "location_id": locations[selectedLocation]['location_id']
    };
    ApiService()
        .postAllUrl(indexKey.currentContext!, "${customUrl}get_visitor_record",
            params: data)
        .then((value) {
      if (value['status'] != "success") {
        // nameControl.clear();
        // mobileControl.clear();
        // emailControl.clear();
        // icNumberCont.clear();
        // contactPerson.clear();
        blockedVehicle = 0;
        notifyListeners();
      } else {
        if (value['blocked_status'] == 1) {
          blockedVehicle = 1;
          notifyListeners();
        }
        nameControl.text = value['data']['name'] ?? nameControl.text;
        mobileControl.text = value['data']['phone'] ?? mobileControl.text;
        emailControl.text = value['data']['email'] ?? emailControl.text;
        icNumberCont.text = value['data']['ic_number'] ?? icNumberCont.text;
        contactPerson.text =
            value['data']['contact_person'] ?? contactPerson.text;
        unitNumberCont.text = value['data']['unit_no'] ?? unitNumberCont.text;
        totalPerson = value['data']['person_count'] ?? 1;
        notifyListeners();
        if (value['data']['purpose_of_visit'] != null) {
          int index = purpose.indexWhere((element) =>
              element['purpose_id'] == value['data']['purpose_of_visit']);
          selectedPurpose = purpose[index];
          notifyListeners();
        }
      }
    });
  }

  String _cleanUnit(String? raw) {
    if (raw == null) return "";
    final s = raw.trim();

    // If it's exactly "#-" (with optional spaces), show empty
    if (RegExp(r'^#-\s*$').hasMatch(s)) return "";

    // If it starts with "#-" (e.g., "#-200" or "#- 200"), strip the prefix
    return s.replaceFirst(RegExp(r'^\s*#-\s*'), '');
  }

  getMobileNumberData(String mobile) {
    var data = {
      "mobile_no": mobile,
      "location_id": locations[selectedLocation]['location_id']
    };
    ApiService()
        .postAllUrl(
            indexKey.currentContext!, "${customUrl}get_visitor_record_mobile",
            params: data)
        .then((value) {
      print(value);
      if (value['status'] != "success") {
        // nameControl.clear();
        // emailControl.clear();
        // icNumberCont.clear();
        // contactPerson.clear();
        // blockedVehicle = 0;
        // notifyListeners();
      } else {
        // vehicleNo.text = value['data']['vehicle_no'] ?? "";
        nameControl.text = value['data']['name'] ?? "";
        emailControl.text = value['data']['email'] ?? "";
        icNumberCont.text = value['data']['ic_number'] ?? "";
        contactPerson.text = value['data']['contact_person'] ?? "";
        unitNumberCont.text = _cleanUnit(value['data']['unit_no']);
        totalPerson = value['data']['person_count'] ?? 1;
        notifyListeners();
        if (value['data']['purpose_of_visit'] != null) {
          int index = purpose.indexWhere((element) =>
              element['purpose_id'] == value['data']['purpose_of_visit']);
          selectedPurpose = purpose[index];
          notifyListeners();
        }
      }
    });
  }

  int blockedVehicle = 0;
  int feedIndex = 0;

  incrementFeedIndex() {
    loadingOn();
    ApiService().postAllUrl(indexKey.currentContext!, "${customUrl}skip_feeds",
        params: {"feed_id": feeds[feedIndex]['id'].toString()}).then((val) {
      getEntryFeed();
    });
  }

  setFeedIndex(int feed) {
    feedIndex = feed;
    vehicleNo.clear();
    Provider.of<LayoutProvider>(indexKey.currentContext!, listen: false)
        .changeNavBar(indexKey.currentContext!, 0);
    Navigator.of(indexKey.currentContext!).pop();
    if (feeds[feedIndex]['license_plate_number'] != null) {
      List<String> stringArray =
          feeds[feedIndex]['license_plate_number'].split("/");
      vehicleNo.text = stringArray[0];
      getVehicleData(stringArray[0]);
      return notifyListeners();
    }
    return notifyListeners();
  }

  addEntry(Map<String, String> data) {
    data.addAll({"entry_feed": feeds[feedIndex]['id'].toString()});
    data.addAll({
      "location_id": locations[selectedLocation]['location_id'].toString(),
      "type": locations[selectedLocation]["is_local"] == 1 ? "1" : "0",
      // "feed": feeds[feedIndex]
    });
    logger.wtf(data);
    commonLoading2 = true;
    notifyListeners();
    ApiService()
        .postAllUrl(
            indexKey.currentContext!, "${customUrl}store_newvisitor_entry",
            params: data)
        .then((received) {
      if (locations[selectedLocation]["is_local"] == 1) incrementFeedIndex();
      commonLoading2 = false;
      notifyListeners();
      getEntryFeed();
      nameControl.clear();
      vehicleNo.clear();
      mobileControl.clear();
      emailControl.clear();
      contactPerson.clear();
      icNumberCont.clear();
      unitNumberCont.clear();
      selectedPurpose = null;
      totalPerson = null;
      getNotReturned(typeNotReturned);
      return notif('Success', received['message']);
    });
  }

  List feedNotReturned = [];

  getNotReturned(int type) {
    loadingOn();
    ApiService()
        .getAllUrl(indexKey.currentContext!,
            "${customUrl}get_not_returned_visitors/${locations[selectedLocation]['location_id']}/$type")
        .then((received) {
      loadingOff();
      if (received['status'] == "success") {
        feedNotReturned = received['visitors']['data'];
        notifyListeners();
        nextNotReturned = received['visitors']['next_page_url'] ?? "0";
        return;
      } else {
        feedNotReturned = [];
        notifyListeners();
        loadingOff();
        return;
      }
    });
  }

  String nextNotReturned = "";
  bool notReturnedLoad = false;

  addNotReturned() {
    if (nextNotReturned != "0") {
      notReturnedLoad = true;
      notifyListeners();
      ApiService()
          .getAllUrl(indexKey.currentContext!, nextNotReturned)
          .then((val) {
        notReturnedLoad = false;
        notifyListeners();
        if (val != null) {
          if (val["status"] == "error") {
            feedNotReturned = [];
            return notifyListeners();
          } else {
            feedNotReturned.addAll(val['visitors']['data']);
            nextNotReturned = val['visitors']['next_page_url'] ?? "0";
            return notifyListeners();
          }
        } else {
          return;
        }
      });
    } else {
      return notif('Failed', "No more visitors to refresh!");
    }
  }

  List unMatched = [];

  getUnMatched() {
    loadingOn();
    ApiService()
        .getAllUrl(indexKey.currentContext!,
            "${customUrl}unmatched_inout_license/${locations[selectedLocation]['location_id']}-0")
        .then((received) {
      loadingOff();
      if (received != null) {
        if (received['data'] != null) {
          unMatched = received['data'];
          notifyListeners();
        } else {
          unMatched = [];
          notifyListeners();
        }
      } else {
        loadingOff();
        return;
      }
    });
  }

  List cameraList = [];

  getCameras() {
    var data = {
      "user_id":
          Provider.of<AuthProvider>(indexKey.currentContext!, listen: false)
              .id
              .toString(),
      "location_id": locations[selectedLocation]['location_id'],
    };
    ApiService()
        .postAllUrl(indexKey.currentContext!, "${customUrl}get_cameras",
            params: data)
        .then((received) {
      if (received != null) {
        if (received['status'] == "success") {
          cameraList = received['cameras'];
          getCameraSetting(locations[selectedLocation]['location_id']);
          notifyListeners();
          return;
        }
        return;
      }
      return;
    });
  }

  storeSetting() {
    var data = {
      "user_id":
          Provider.of<AuthProvider>(indexKey.currentContext!, listen: false)
              .id
              .toString(),
      "location_id": locations[selectedLocation]['location_id'],
      "entry_camera": cameraList[entryCameraInt]['feed_id'],
      "exit_camera": cameraList[exitCameraInt]['feed_id'],
    };
    if (exitCameraInt == entryCameraInt) {
      notif('Failed', "Select different entry and exit camera");
      return;
    }
    ApiService()
        .postAllUrl(indexKey.currentContext!, "${customUrl}store_setting",
            params: data)
        .then((received) {
      if (received != null) {
        if (received['status'] == "success") {
          notif('Success', received['messages']);
          getUnMatched();
          getNotReturned(typeNotReturned);
          getEntryFeed();
          return Navigator.of(indexKey.currentContext!).pop();
        }
        return Navigator.of(indexKey.currentContext!).pop();
      }
      return Navigator.of(indexKey.currentContext!).pop();
    });
  }

  int entryCameraInt = 0;
  int exitCameraInt = 0;

  setEntryCameraInt(int int) {
    entryCameraInt = int;
    notifyListeners();
  }

  setExitCameraInt(int int) {
    exitCameraInt = int;
    notifyListeners();
  }

  getCameraSetting(String locationId) {
    var data = {
      "user_id":
          Provider.of<AuthProvider>(indexKey.currentContext!, listen: false)
              .id
              .toString(),
      "location_id": locationId,
    };
    ApiService()
        .postAllUrl(indexKey.currentContext!, "${customUrl}user_setting",
            params: data)
        .then((received) {
      if (received != null) {
        if (received['status'] == "success") {
          List sample = Provider.of<CommonProvider>(indexKey.currentContext!,
                  listen: false)
              .cameraList;
          entryCameraInt = sample.indexWhere((element) =>
              element['feed_id'] == received['data']['entry_camera']);
          exitCameraInt = sample.indexWhere((element) =>
              element['feed_id'] == received['data']['exit_camera']);
          notifyListeners();
        }
        return;
      }
      return;
    });
  }

  List listHistory = [];
  String nextListHistory = "";

  getHistory(int type, String search) {
    loadingOn();
    ApiService()
        .getAllUrl(indexKey.currentContext!,
            "${customUrl}get_all_visitor?location_id=${locations[selectedLocation]['location_id']}&search=$search&entry_type=$type")
        .then((received) {
      loadingOff();
      if (received['status'] == "success") {
        listHistory = received['visitors']['data'];
        notifyListeners();
        nextListHistory = received['visitors']['next_page_url'] ?? "0";
        return;
      } else {
        listHistory = [];
        notifyListeners();
        loadingOff();
        return;
      }
    });
  }

  addHistory() {
    if (nextListHistory != "0") {
      ApiService()
          .getAllUrl(indexKey.currentContext!, nextListHistory)
          .then((received) {
        notifyListeners();
        if (received['status'] == "success") {
          listHistory.addAll(received['visitors']['data']);
          notifyListeners();
          nextListHistory = received['visitors']['next_page_url'] ?? "0";
          return;
        } else {
          listHistory = [];
          notifyListeners();
          loadingOff();
          return;
        }
      });
    } else {
      return notif('Failed', "No more visitors to refresh!");
    }
  }
}
