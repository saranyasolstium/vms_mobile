// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
import 'package:vms_mobile_app/utilities/notifications.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Future.error('Location services are disabled.');
    return notif('Failed', "Turn on GPS/Location");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Future.error('Location permissions are denied');
      return notif('Failed', "GPS/Location Permission Denied!");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    //  Future.error('Location permissions are permanently denied, we cannot request permissions.');
    return notif('Failed', "GPS/Location permanently Permission Denied!");
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}
