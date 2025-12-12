import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // <-- NEW
import 'package:image/image.dart' as img; // <-- NEW
import 'package:vms_mobile_app/utilities/notifications.dart';

// === loads the saved settings and prints the current visitor ===
Future<void> printWithSavedPrefs(
    BuildContext context, Map<String, dynamic> v) async {
  // 1) Load saved prefs (same keys you used in PrintWifi)
  final prefs = await SharedPreferences.getInstance();
  final ip = prefs.getString('printer_ip') ?? '192.168.1.251';
  final portS = prefs.getString('printer_port') ?? '9100';
  final is80 = prefs.getBool('printer_paper_is80mm') ?? true;

  final port = int.tryParse(portS) ?? 9100;

  // 2) Setup printer
  final paper = is80 ? PaperSize.mm80 : PaperSize.mm58;
  final profile = await CapabilityProfile.load();
  final printer = NetworkPrinter(paper, profile);

  // 3) Connect
  final res = await printer.connect(ip, port: port);
  if (res != PosPrintResult.success) {
    notif('Failed', 'Cannot connect: ${res.msg}');
    return;
  }

  try {
    // 4) Build visitor parking slip
    await _printVisitorReceipt(printer, v);
    printer.cut();
    notif('Success', 'Printed');
  } catch (e) {
    notif('Failed', 'Build error: $e');
  } finally {
    printer.disconnect();
  }
}

Future<void> _printVisitorReceipt(
  NetworkPrinter printer,
  Map<String, dynamic> v,
) async {
  final dfIn = DateFormat('yyyy-MM-dd HH:mm:ss'); // API format
  final dfOut = DateFormat('dd MMM yyyy hh:mm a'); // ticket display

  String? inStr = (v['in_time'] ?? '').toString().trim().isEmpty
      ? null
      : v['in_time'].toString().trim();
  DateTime? inDt = inStr != null ? dfIn.parseStrict(inStr) : null;

  // We only really need vehicle, purpose & entry for this slip
  String vehicleNo = v['vehicle_no'] ?? '-';
  String purpose = v['visit_reason']?['purpose'] ?? '-';
  final other = (v['other'] ?? '').toString();
  if (other.isNotEmpty) {
    purpose = purpose.isNotEmpty ? '$purpose - $other' : other;
  }

  // ----------------- HEADER -----------------

  // LOGO from assets (centered)
  try {
    final bytes = await rootBundle.load('assets/images/skywood_logo.png');
    final buffer = bytes.buffer;
    final logo = img.decodeImage(buffer.asUint8List());
    if (logo != null) {
      // Optionally resize to fit receipt width nicely
      final resized = img.copyResize(logo, width: 200);
      printer.image(
        resized,
        align: PosAlign.center,
      );
    }
  } catch (e) {
    // If logo fails, just ignore and continue printing
  }

  // Main title: same size as previous header (size2 x size2, bold, centered)
  printer.text(
    "Visitor's Parking Slip",
    styles: const PosStyles(
      bold: true,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
      align: PosAlign.center,
    ),
    linesAfter: 1,
  );

  // ----------------- BODY -----------------

  printer.text(
    'Vehicle No : $vehicleNo',
    styles: const PosStyles(
      align: PosAlign.left,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );

  printer.text(
    'Purpose    : $purpose',
    styles: const PosStyles(
      align: PosAlign.left,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );

  if (inDt != null) {
    printer.text(
      'Entry      : ${dfOut.format(inDt)}',
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
  } else {
    printer.text(
      'Entry      : -',
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
  }

  printer.feed(1);

  // ----------------- FOOTER NOTE -----------------

  printer.text(
    'Please display this slip on the Dashboard.',
    styles: const PosStyles(
      align: PosAlign.left,
      bold: true,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ),
  );

  printer.feed(2);
}
