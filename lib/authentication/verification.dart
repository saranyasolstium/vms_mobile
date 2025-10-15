import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/buttons.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/provider/auth_provider.dart';
import 'package:vms_mobile_app/service/api_service.dart';
import 'package:vms_mobile_app/utilities/fonts.dart';
import 'package:vms_mobile_app/utilities/loaders.dart';
import 'package:vms_mobile_app/utilities/notifications.dart';

import '../provider/common_provider.dart';
import '../service/locations.dart';
import '../utilities/color.dart';
import 'location_select.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.page});
  final bool page;
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String? latitude;
  String? longitude;
  bool locationLoading = false;

  getLocation() async {
    // await Geolocator.getLastKnownPosition();
    setState(() {
      locationLoading = true;
    });
    var position = await determinePosition();
    setState(() {
      locationLoading = false;
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  final picker = ImagePicker();
  late String base64Image;
  File? _image;

  Future getCamera() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {}
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getLocation());
    super.initState();
  }

  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
          onWillPop: () async {
            return notif('Failed', "Shif Over - Verify or Skip");
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: CColors.dark,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(child: SafeArea(child: SizedBox())),
                const SizedBox(height: 24),
                textHeading("Attendance"),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textSideHeading("Code"),
                    const SizedBox(width: 8),
                    if (codeController.text.length >= 4)
                      const Icon(Icons.done, color: CColors.success, size: 18)
                  ],
                ),
                const SizedBox(height: 12),
                authFieldCenter(codeController),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textSideHeading("Location"),
                    const SizedBox(width: 8),
                    if (latitude != "null")
                      const Icon(Icons.done, color: CColors.success, size: 18)
                  ],
                ),
                const SizedBox(height: 12),
                textDesc("Latitude: $latitude"),
                const SizedBox(height: 6),
                textDesc("Longitude: $longitude"),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textSideHeading("Face Camera"),
                    const SizedBox(width: 8),
                    if (_image != null)
                      const Icon(Icons.done, color: CColors.success, size: 18)
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: SizedBox(
                        height: 150,
                        width: 150,
                        child: _image == null
                            ? IconButton(
                                onPressed: () => getCamera(),
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.grey, size: 52))
                            : Align(
                                alignment: Alignment.center,
                                child: Image.file(_image!, fit: BoxFit.fill)))),
                const SizedBox(height: 24),
                loading
                    ? loading50Button()
                    : buttonPrimary("Make Attendance", () => checkAttendance()),
                const SizedBox(height: 12),
                widget.page
                    ? const SizedBox()
                    : buttonSecondaryOutline(
                        "Skip >>",
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SelectLocation())))
              ],
            ),
          )),
    );
  }

  String locationId = "";
  bool loading = false;

  checkAttendance() {
    if (codeController.text.isEmpty) {
      notif('Failed', "Enter your code");
      return FocusScope.of(context).nextFocus();
    }
    if (latitude == "" || latitude == "null") {
      notif('Failed', "Fetching your location");
      return getLocation();
    }
    if (_image == null) {
      getCamera();
      return;
    }
    getLocationID(context);
    String location = "$latitude" "/" "$longitude";
    var data = {
      "location_id": locationId,
      "user_id":
          Provider.of<AuthProvider>(context, listen: false).id.toString(),
      "geo_location": location,
      "security_code": codeController.text,
      "photo": _image != null
          ? base64Image = base64Encode(_image!.readAsBytesSync())
          : "",
    };
    setState(() {
      loading = true;
    });
    ApiService()
        .post(context, "store_attendance", params: data)
        .then((received) {
      setState(() {
        loading = false;
      });
      if (received != null) {
        if (received['status'] == "success") {
          notif('Success', received['message']);
          if (widget.page) {
            return Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const SelectLocation()),
                (route) => false);
          }
        } else {
          notif('Failed', received['message']);
          return;
        }
      }
    });

    // Navigator.of(context).pop();
  }

  getLocationID(BuildContext context) {
    locationId = Provider.of<CommonProvider>(context, listen: false).locations[
        Provider.of<CommonProvider>(context, listen: false)
            .selectedLocation]['location_id'];
  }
}
