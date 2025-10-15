import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:vibration/vibration.dart';
import 'package:vms_mobile_app/main.dart';

class BarcodeProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isGettingProducts = false;
  String barcodeScanRes = '';
  bool isMuted = false;
  bool isVibrateOff = false;
  bool forceLoop = false;
  List products = [];
  List scannedProducts = [];

  void loadingON() {
    isLoading = true;
    notifyListeners();
  }

  void loadingOFF() {
    isLoading = false;
    notifyListeners();
  }

  /// Scan a single barcode and return the content (first 9 chars like before).
  /// Returns '' on cancel or error.
  Future<String> scanBarcode() async {
    if (isLoading) return '';
    loadingON();
    try {
      final result = await BarcodeScanner.scan(
        options: const ScanOptions(
          strings: {
            'cancel': 'Cancel',
            'flash_on': 'Flash on',
            'flash_off': 'Flash off',
          },
          useCamera: -1, // default camera
          autoEnableFlash: false,
          android: AndroidOptions(
            useAutoFocus: true,
            aspectTolerance: 0.5,
          ),
        ),
      );

      if (result.type == ResultType.Cancelled) {
        return '';
      }

      final raw = result.rawContent.trim();
      if (raw.isEmpty) return '';

      if (!isVibrateOff && (await Vibration.hasVibrator() ?? false)) {
        await Vibration.vibrate(duration: 250);
      }

      // Keep your previous behavior: log & return first 9 characters
      final first9 = raw.length > 9 ? raw.substring(0, 9) : raw;
      logger.i('Scanned: $first9');
      barcodeScanRes = first9;
      return first9;
    } on PlatformException catch (e) {
      logger.e('Barcode scan error: $e');
      return '';
    } catch (e) {
      logger.e('Unexpected scan error: $e');
      return '';
    } finally {
      loadingOFF();
    }
  }
}
