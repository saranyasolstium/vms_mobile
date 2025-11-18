import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vms_mobile_app/decoration/buttons.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/utilities/notifications.dart';

import '../../utilities/color.dart';
import '../../utilities/fonts.dart';

class PrintWifi extends StatefulWidget {
  const PrintWifi({Key? key}) : super(key: key);

  @override
  State<PrintWifi> createState() => _PrintWifiState();
}

class _PrintWifiState extends State<PrintWifi> {
  // --- controllers ---
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  // --- prefs keys ---
  static const _kIp = 'printer_ip';
  static const _kPort = 'printer_port';
  static const _kPaper = 'printer_paper_is80mm';

  // --- UI state ---
  bool paper80mm = true; // true => 80mm, false => 58mm
  bool _loading = true;
  DateTime? _lastSavedAt;

  // defaults
  static const _defaultIp = '192.168.1.251';
  static const _defaultPort = '9100';
  static const _defaultPaper80 = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_kIp) ?? _defaultIp;
    final port = prefs.getString(_kPort) ?? _defaultPort;
    final is80 = prefs.getBool(_kPaper) ?? _defaultPaper80;

    setState(() {
      ipController.text = ip;
      portController.text = port;
      paper80mm = is80;
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kIp, ipController.text.trim());
    await prefs.setString(_kPort, portController.text.trim());
    await prefs.setBool(_kPaper, paper80mm);
    setState(() => _lastSavedAt = DateTime.now());
    notif('Saved', 'Printer settings saved');
  }

  Future<void> _resetDefaults() async {
    setState(() {
      ipController.text = _defaultIp;
      portController.text = _defaultPort;
      paper80mm = _defaultPaper80;
    });
    await _savePrefs();
  }

  bool _validate() {
    final ip = ipController.text.trim();
    final portStr = portController.text.trim();

    if (ip.isEmpty) {
      notif('Validation', 'IP address is required');
      return false;
    }
    // very light IP/domain validation
    final ipRegex = RegExp(r'^[a-zA-Z0-9\.\-]+$');
    if (!ipRegex.hasMatch(ip)) {
      notif('Validation', 'Invalid IP/Host format');
      return false;
    }
    if (portStr.isEmpty) {
      notif('Validation', 'Port is required');
      return false;
    }
    final port = int.tryParse(portStr);
    if (port == null || port <= 0 || port > 65535) {
      notif('Validation', 'Port must be between 1 and 65535');
      return false;
    }
    return true;
  }

  Future<void> _onTestPrint() async {
    if (!_validate()) return;
    // Save before printing so the latest edits persist
    await _savePrefs();
    final port = int.parse(portController.text.trim());
    await printWifiConnect(ipController.text.trim(), port, paper80mm);
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: CColors.dark,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CColors.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 24),
              textHeading("Print Wifi/Network"),
              const SizedBox(height: 24),

              // IP
              Align(
                  alignment: Alignment.centerLeft,
                  child: textSideHeading("Printer IP")),
              const SizedBox(height: 8),
              authFieldCenter(
                ipController,
                // If your authFieldCenter supports keyboardType, pass it there.
              ),

              const SizedBox(height: 16),

              // Port
              Align(
                  alignment: Alignment.centerLeft,
                  child: textSideHeading("Printer Port")),
              const SizedBox(height: 8),
              authFieldCenter(
                portController,
                // enforce numeric entry
              ),
              // Also restrict input to digits
              // If authFieldCenter doesn’t accept inputFormatters, wrap with your own TextField instead.
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: '9100',
                ),
                style: const TextStyle(
                    color: Colors.transparent,
                    fontSize:
                        0), // hidden dummy to keep your UI; remove if not needed
              ),

              const SizedBox(height: 16),

              // Paper size
              Align(
                  alignment: Alignment.centerLeft,
                  child: textSideHeading("Paper Size")),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => paper80mm = true),
                    icon: paper80mm
                        ? const Icon(Icons.radio_button_on,
                            color: CColors.brand1, size: 24)
                        : const Icon(Icons.radio_button_off,
                            color: CColors.brand1, size: 24),
                  ),
                  const SizedBox(width: 12),
                  textSideHeading("80mm"),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () => setState(() => paper80mm = false),
                    icon: paper80mm
                        ? const Icon(Icons.radio_button_off,
                            color: CColors.brand1, size: 24)
                        : const Icon(Icons.radio_button_on,
                            color: CColors.brand1, size: 24),
                  ),
                  const SizedBox(width: 12),
                  textSideHeading("58mm"),
                ],
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: buttonPrimary("Save", _savePrefs),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buttonPrimary("Test Print", _onTestPrint),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetDefaults,
                      child: const Text("Reset to Defaults"),
                    ),
                  ),
                ],
              ),

              if (_lastSavedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Last saved: ${_lastSavedAt!.toLocal()}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Printing helpers (unchanged) ----------------

Future printWifiConnect(String ip, int port, bool pap) async {
  PaperSize paper = pap ? PaperSize.mm80 : PaperSize.mm58;
  final profile = await CapabilityProfile.load();
  final printer = NetworkPrinter(paper, profile);

  final PosPrintResult res = await printer.connect(ip, port: port);

  if (res == PosPrintResult.success) {
    testReceipt(printer);
    printer.disconnect();
    notif('Success', "Print Success");
  } else {
    notif('Failed', 'Er: ${res.msg}');
  }
}

void testReceipt(NetworkPrinter printer) {
  printer.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
      styles: const PosStyles(codeTable: 'CP1252'));
  printer.text('Special 2: blåbærgrød',
      styles: const PosStyles(codeTable: 'CP1252'));

  printer.text('Bold text', styles: const PosStyles(bold: true));
  printer.text('Reverse text', styles: const PosStyles(reverse: true));
  printer.text('Underlined text',
      styles: const PosStyles(underline: true), linesAfter: 1);
  printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
  printer.text('Align center', styles: const PosStyles(align: PosAlign.center));
  printer.text('Align right',
      styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

  printer.text('Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  printer.feed(2);
  printer.cut();
}



// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:vms_mobile_app/decoration/buttons.dart';
// import 'package:vms_mobile_app/decoration/text_fields.dart';
// import 'package:vms_mobile_app/utilities/notifications.dart';

// import '../../utilities/color.dart';
// import '../../utilities/fonts.dart';

// class PrintWifi extends StatefulWidget {
//   const PrintWifi({Key? key}) : super(key: key);

//   @override
//   State<PrintWifi> createState() => _PrintWifiState();
// }

// class _PrintWifiState extends State<PrintWifi> {
//   TextEditingController ipController = TextEditingController();
//   TextEditingController portController = TextEditingController();

//   initial() {
//     setState(() {
//       ipController.text = "192.168.1.251";
//       portController.text = "9100";
//     });
//   }

//   bool paper = true;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 100), () {
//       initial();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: CColors.dark,
//       body: SafeArea(
//         child: SizedBox(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 24),
//                 textHeading("Print Wifi/Network"),
//                 const SizedBox(height: 24),
//                 textSideHeading("Printer IP"),
//                 const SizedBox(height: 8),
//                 authFieldCenter(ipController),
//                 textSideHeading("Printer Port"),
//                 const SizedBox(height: 8),
//                 authFieldCenter(portController),
//                 const SizedBox(height: 8),
//                 textSideHeading("Paper Size"),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                         onPressed: () => setState(() {
//                               paper = true;
//                             }),
//                         icon: paper
//                             ? const Icon(Icons.radio_button_on,
//                                 color: CColors.brand1, size: 24)
//                             : const Icon(Icons.radio_button_off,
//                                 color: CColors.brand1, size: 24)),
//                     const SizedBox(width: 12),
//                     textSideHeading("80mm"),
//                     const SizedBox(width: 12),
//                     IconButton(
//                         onPressed: () => setState(() {
//                               paper = false;
//                             }),
//                         icon: paper
//                             ? const Icon(Icons.radio_button_off,
//                                 color: CColors.brand1, size: 24)
//                             : const Icon(Icons.radio_button_on,
//                                 color: CColors.brand1, size: 24)),
//                     const SizedBox(width: 12),
//                     textSideHeading("58mm"),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 buttonPrimary(
//                     "Test Print",
//                     () => printWifiConnect(ipController.text,
//                         int.parse(portController.text), paper))
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Future printWifiConnect(String ip, int port, bool pap) async {
//   PaperSize paper = pap ? PaperSize.mm80 : PaperSize.mm58;
//   final profile = await CapabilityProfile.load();
//   final printer = NetworkPrinter(paper, profile);

//   final PosPrintResult res = await printer.connect(ip, port: port);

//   if (res == PosPrintResult.success) {
//     testReceipt(printer);
//     printer.disconnect();
//     notif('Success', "Print Success");
//   }
//   notif('Failed', 'Er:${res.msg}');
// }

// void testReceipt(NetworkPrinter printer) {
//   printer.text(
//       'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//   printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//       styles: const PosStyles(codeTable: 'CP1252'));
//   printer.text('Special 2: blåbærgrød',
//       styles: const PosStyles(codeTable: 'CP1252'));

//   printer.text('Bold text', styles: const PosStyles(bold: true));
//   printer.text('Reverse text', styles: const PosStyles(reverse: true));
//   printer.text('Underlined text',
//       styles: const PosStyles(underline: true), linesAfter: 1);
//   printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
//   printer.text('Align center', styles: const PosStyles(align: PosAlign.center));
//   printer.text('Align right',
//       styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

//   printer.text('Text size 200%',
//       styles: const PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ));

//   printer.feed(2);
//   printer.cut();
// }
