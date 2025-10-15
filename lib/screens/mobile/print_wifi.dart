import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
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
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();

  initial() {
    setState(() {
      ipController.text = "192.168.1.251";
      portController.text = "9100";
    });
  }

  bool paper = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      initial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.dark,
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                textHeading("Print Wifi/Network"),
                const SizedBox(height: 24),
                textSideHeading("Printer IP"),
                const SizedBox(height: 8),
                authFieldCenter(ipController),
                textSideHeading("Printer Port"),
                const SizedBox(height: 8),
                authFieldCenter(portController),
                const SizedBox(height: 8),
                textSideHeading("Paper Size"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () => setState(() {
                              paper = true;
                            }),
                        icon: paper
                            ? const Icon(Icons.radio_button_on,
                                color: CColors.brand1, size: 24)
                            : const Icon(Icons.radio_button_off,
                                color: CColors.brand1, size: 24)),
                    const SizedBox(width: 12),
                    textSideHeading("80mm"),
                    const SizedBox(width: 12),
                    IconButton(
                        onPressed: () => setState(() {
                              paper = false;
                            }),
                        icon: paper
                            ? const Icon(Icons.radio_button_off,
                                color: CColors.brand1, size: 24)
                            : const Icon(Icons.radio_button_on,
                                color: CColors.brand1, size: 24)),
                    const SizedBox(width: 12),
                    textSideHeading("58mm"),
                  ],
                ),
                const SizedBox(height: 24),
                buttonPrimary(
                    "Test Print",
                    () => printWifiConnect(ipController.text,
                        int.parse(portController.text), paper))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future printWifiConnect(String ip, int port, bool pap) async {
  PaperSize paper = pap ? PaperSize.mm80 : PaperSize.mm58;
  final profile = await CapabilityProfile.load();
  final printer = NetworkPrinter(paper, profile);

  final PosPrintResult res = await printer.connect(ip, port: port);

  if (res == PosPrintResult.success) {
    testReceipt(printer);
    printer.disconnect();
    notif('Success', "Print Success");
  }
  notif('Failed', 'Er:${res.msg}');
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
