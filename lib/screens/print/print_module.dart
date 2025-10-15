// import 'package:flutter/material.dart';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';

// class PrinterPage extends StatefulWidget {
//   const PrinterPage({super.key});

//   @override
//   State<PrinterPage> createState() => _PrinterPageState();
// }

// class _PrinterPageState extends State<PrinterPage> {
//   BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//   List<BluetoothDevice> devices = [];
//   BluetoothDevice? selectedDevice;
//   bool connected = false;
//   final TextEditingController _txtText =
//       TextEditingController(text: "Hello developer");
//   String _msj = '';

//   @override
//   void initState() {
//     super.initState();
//     initPrinter();
//   }

//   void initPrinter() async {
//     bool? isAvailable = await bluetooth.isAvailable;
//     if (isAvailable ?? false) {
//       devices = await bluetooth.getBondedDevices();
//       setState(() {});
//     }
//   }

//   void connect(BluetoothDevice device) async {
//     await bluetooth.connect(device);
//     setState(() {
//       selectedDevice = device;
//       connected = true;
//       _msj = "Connected to ${device.name}";
//     });
//   }

//   void disconnect() async {
//     await bluetooth.disconnect();
//     setState(() {
//       connected = false;
//       _msj = "Disconnected";
//     });
//   }

//   void printTest() async {
//     if (!connected) return;

//     bluetooth.printNewLine();
//     bluetooth.printCustom("Test Print", 3, 1);
//     bluetooth.printNewLine();
//     bluetooth.printCustom("Hello developer", 2, 1);
//     bluetooth.printNewLine();
//     bluetooth.paperCut();
//   }

//   void printCustomText() async {
//     if (!connected) return;

//     String text = _txtText.text;
//     bluetooth.printNewLine();
//     bluetooth.printCustom(text, 2, 1);
//     bluetooth.printNewLine();
//     bluetooth.paperCut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Bluetooth Printer')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(_msj),
//             ElevatedButton(
//               onPressed: initPrinter,
//               child: const Text("Search Devices"),
//             ),
//             if (devices.isNotEmpty)
//               ...devices.map((device) => ListTile(
//                     title: Text(device.name ?? ''),
//                     subtitle: Text(device.address ?? ''),
//                     onTap: () => connect(device),
//                   )),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _txtText,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Text to Print",
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: connected ? printCustomText : null,
//                     child: const Text("Print"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: connected ? disconnect : null,
//                   child: const Text("Disconnect"),
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: connected ? printTest : null,
//               child: const Text("Print Test Receipt"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


// // import 'dart:async';
// // import 'package:esc_pos_utils/esc_pos_utils.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter/material.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// // import '../../main.dart';

// // class PrinterPage extends StatefulWidget {
// //   const PrinterPage({super.key});

// //   @override
// //   State<PrinterPage> createState() => _PrinterPageState();
// // }

// // class _PrinterPageState extends State<PrinterPage> {
// //   String _info = "";
// //   String _msj = '';
// //   bool connected = false;
// //   List<BluetoothInfo> items = [];
// //   final List<String> _options = [
// //     "permission bluetooth granted",
// //     "bluetooth enabled",
// //     "connection status",
// //     "update info"
// //   ];

// //   String _selectSize = "2";
// //   final _txtText = TextEditingController(text: "Hello developer");
// //   bool _connceting = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initPlatformState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Plugin example app'),
// //           actions: [
// //             PopupMenuButton(
// //               elevation: 3.2,
// //               //initialValue: _options[1],
// //               onCanceled: () {
// //                 logger.v('You have not chossed anything');
// //               },
// //               tooltip: 'Menu',
// //               onSelected: (Object select) async {
// //                 String sel = select as String;
// //                 logger.v("selected: $sel");
// //                 if (sel == "permission bluetooth granted") {
// //                   bool status =
// //                       await PrintBluetoothThermal.isPermissionBluetoothGranted;
// //                   setState(() {
// //                     _info = "permission bluetooth granted: $status";
// //                   });
// //                 } else if (sel == "bluetooth enabled") {
// //                   bool state = await PrintBluetoothThermal.bluetoothEnabled;
// //                   setState(() {
// //                     _info = "Bluetooth enabled: $state";
// //                   });
// //                 } else if (sel == "update info") {
// //                   initPlatformState();
// //                 } else if (sel == "connection status") {
// //                   final bool result =
// //                       await PrintBluetoothThermal.connectionStatus;
// //                   setState(() {
// //                     _info = "connection status: $result";
// //                   });
// //                 }
// //               },
// //               itemBuilder: (BuildContext context) {
// //                 return _options.map((String option) {
// //                   return PopupMenuItem(
// //                     value: option,
// //                     child: Text(option),
// //                   );
// //                 }).toList();
// //               },
// //             )
// //           ],
// //         ),
// //         body: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: Container(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text('info: $_info\n '),
// //                 Text(_msj),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                   children: [
// //                     ElevatedButton(
// //                       onPressed: () => getBluetoots(),
// //                       child: Row(
// //                         children: [
// //                           Visibility(
// //                             visible: _connceting,
// //                             child: const SizedBox(
// //                               width: 25,
// //                               height: 25,
// //                               child: CircularProgressIndicator(
// //                                   strokeWidth: 1,
// //                                   backgroundColor: Colors.white),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 5),
// //                           Text(_connceting ? "Connecting" : "Search"),
// //                         ],
// //                       ),
// //                     ),
// //                     ElevatedButton(
// //                       onPressed: connected ? disconnect : null,
// //                       child: const Text("Disconnect"),
// //                     ),
// //                     ElevatedButton(
// //                       onPressed: connected ? printTest : null,
// //                       child: const Text("Test"),
// //                     ),
// //                   ],
// //                 ),
// //                 Container(
// //                     height: 200,
// //                     decoration: BoxDecoration(
// //                       borderRadius: const BorderRadius.all(Radius.circular(10)),
// //                       color: Colors.grey.withOpacity(0.3),
// //                     ),
// //                     child: ListView.builder(
// //                       itemCount: items.isNotEmpty ? items.length : 0,
// //                       itemBuilder: (context, index) {
// //                         return ListTile(
// //                           onTap: () {
// //                             String mac = items[index].macAdress;
// //                             connect(mac);
// //                           },
// //                           title: Text('Name: ${items[index].name}'),
// //                           subtitle:
// //                               Text("macAdress: ${items[index].macAdress}"),
// //                         );
// //                       },
// //                     )),
// //                 const SizedBox(
// //                   height: 10,
// //                 ),
// //                 Container(
// //                   padding: const EdgeInsets.all(10),
// //                   decoration: BoxDecoration(
// //                     borderRadius: const BorderRadius.all(Radius.circular(10)),
// //                     color: Colors.grey.withOpacity(0.3),
// //                   ),
// //                   child: Column(children: [
// //                     const Text(
// //                         "Text size without the library without external packets, print images still it should not use a library"),
// //                     const SizedBox(height: 10),
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: TextField(
// //                             controller: _txtText,
// //                             decoration: const InputDecoration(
// //                               border: OutlineInputBorder(),
// //                               labelText: "Text",
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 5),
// //                         DropdownButton<String>(
// //                           hint: const Text('Size'),
// //                           value: _selectSize,
// //                           items: <String>['1', '2', '3', '4', '5']
// //                               .map((String value) {
// //                             return DropdownMenuItem<String>(
// //                               value: value,
// //                               child: Text(value),
// //                             );
// //                           }).toList(),
// //                           onChanged: (String? select) {
// //                             setState(() {
// //                               _selectSize = select.toString();
// //                             });
// //                           },
// //                         )
// //                       ],
// //                     ),
// //                     ElevatedButton(
// //                       onPressed: connected ? printWithoutPackage : null,
// //                       child: const Text("Print"),
// //                     ),
// //                   ]),
// //                 ),
// //                 const SizedBox(
// //                   height: 10,
// //                 ),
// //                 /*OutlinedButton(
// //                   onPressed: conceted ? this.imprimirTicket : null,
// //                   child: Text("Imprimir ticket"),
// //                 ),
// //                 OutlinedButton(
// //                   onPressed: conceted ? this.imprimirTextoPersonalizado : null,
// //                   child: Text("Imprimir texto personalizado"),
// //                 ),
// //                 OutlinedButton(
// //                   onPressed: conceted ? this.imprimirTesh : null,
// //                   child: Text("test"),
// //                 ),
// //                 OutlinedButton(
// //                   onPressed: this.getStatedBluetooth,
// //                   child: Text("stated bluetooth"),
// //                 ),*/
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> initPlatformState() async {
// //     String platformVersion;
// //     int porcentbatery = 0;
// //     // Platform messages may fail, so we use a try/catch PlatformException.
// //     try {
// //       platformVersion = await PrintBluetoothThermal.platformVersion;
// //       porcentbatery = await PrintBluetoothThermal.batteryLevel;
// //     } on PlatformException {
// //       platformVersion = 'Failed to get platform version.';
// //     }

// //     // If the widget was removed from the tree while the asynchronous platform
// //     // message was in flight, we want to discard the reply rather than calling
// //     // setState to update our non-existent appearance.
// //     if (!mounted) return;

// //     final bool result = await PrintBluetoothThermal.bluetoothEnabled;
// //     //print("bluetooth enabled: $result");
// //     if (result) {
// //       _msj = "Bluetooth enabled, please search and connect";
// //     } else {
// //       _msj = "Bluetooth not enabled";
// //     }

// //     setState(() {
// //       _info = "$platformVersion ($porcentbatery% battery)";
// //     });
// //   }

// //   Future<void> getBluetoots() async {
// //     final List<BluetoothInfo> listResult =
// //         await PrintBluetoothThermal.pairedBluetooths;

// //     /*await Future.forEach(listResult, (BluetoothInfo bluetooth) {
// //       String name = bluetooth.name;
// //       String mac = bluetooth.macAdress;
// //     });*/

// //     if (listResult.isEmpty) {
// //       _msj =
// //           "There are no bluetoohs linked, go to settings and link the printer";
// //     } else {
// //       _msj = "Touch an item in the list to connect";
// //     }

// //     setState(() {
// //       items = listResult;
// //     });
// //   }

// //   Future<void> connect(String mac) async {
// //     setState(() {
// //       _connceting = true;
// //     });
// //     final bool result =
// //         await PrintBluetoothThermal.connect(macPrinterAddress: mac);
// //     if (result) connected = true;
// //     setState(() {
// //       _connceting = false;
// //     });
// //   }

// //   Future<void> disconnect() async {
// //     final bool status = await PrintBluetoothThermal.disconnect;
// //     setState(() {
// //       connected = false;
// //     });
// //     logger.v("status disconnect $status");
// //   }

// //   Future<void> printTest() async {
// //     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
// //     if (conexionStatus) {
// //       List<int> ticket = await testTicket();
// //       final result = await PrintBluetoothThermal.writeBytes(ticket);
// //       logger.v("impresion $result");
// //     } else {
// //       //no conectado, reconecte
// //     }
// //   }

// //   Future<void> printString() async {
// //     bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
// //     if (conexionStatus) {
// //       String enter = '\n';
// //       await PrintBluetoothThermal.writeBytes(enter.codeUnits);
// //       //size of 1-5
// //       String text = "Hello";
// //       await PrintBluetoothThermal.writeString(
// //           printText: PrintTextSize(size: 1, text: text));
// //       await PrintBluetoothThermal.writeString(
// //           printText: PrintTextSize(size: 2, text: "$text size 2"));
// //       await PrintBluetoothThermal.writeString(
// //           printText: PrintTextSize(size: 3, text: "$text size 3"));
// //     } else {
// //       //desconectado
// //       logger.v("desconectado bluetooth $conexionStatus");
// //     }
// //   }

// //   Future<List<int>> testTicket() async {
// //     List<int> bytes = [];
// //     // Using default profile
// //     final profile = await CapabilityProfile.load();
// //     final generator = Generator(PaperSize.mm58, profile);
// //     //bytes += generator.setGlobalFont(PosFontType.fontA);
// //     bytes += generator.reset();

// //     bytes += generator.text(
// //         'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
// //         styles: const PosStyles());
// //     bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
// //         styles: const PosStyles(codeTable: 'CP1252'));
// //     bytes += generator.text(
// //       'Special 2: blåbærgrød',
// //       styles: const PosStyles(codeTable: 'CP1252'),
// //     );

// //     bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
// //     bytes +=
// //         generator.text('Reverse text', styles: const PosStyles(reverse: true));
// //     bytes += generator.text('Underlined text',
// //         styles: const PosStyles(underline: true), linesAfter: 1);
// //     bytes += generator.text('Align left',
// //         styles: const PosStyles(align: PosAlign.left));
// //     bytes += generator.text('Align center',
// //         styles: const PosStyles(align: PosAlign.center));
// //     bytes += generator.text('Align right',
// //         styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

// //     bytes += generator.row([
// //       PosColumn(
// //         text: 'col3',
// //         width: 3,
// //         styles: const PosStyles(align: PosAlign.center, underline: true),
// //       ),
// //       PosColumn(
// //         text: 'col6',
// //         width: 6,
// //         styles: const PosStyles(align: PosAlign.center, underline: true),
// //       ),
// //       PosColumn(
// //         text: 'col3',
// //         width: 3,
// //         styles: const PosStyles(align: PosAlign.center, underline: true),
// //       ),
// //     ]);

// //     //barcode
// //     final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
// //     bytes += generator.barcode(Barcode.upcA(barData));

// //     //QR code
// //     bytes += generator.qrcode('example.com');

// //     bytes += generator.text(
// //       'Text size 50%',
// //       styles: const PosStyles(
// //         fontType: PosFontType.fontB,
// //       ),
// //     );
// //     bytes += generator.text(
// //       'Text size 100%',
// //       styles: const PosStyles(
// //         fontType: PosFontType.fontA,
// //       ),
// //     );
// //     bytes += generator.text(
// //       'Text size 200%',
// //       styles: const PosStyles(
// //         height: PosTextSize.size2,
// //         width: PosTextSize.size2,
// //       ),
// //     );

// //     bytes += generator.feed(2);
// //     //bytes += generator.cut();
// //     return bytes;
// //   }

// //   Future<void> printWithoutPackage() async {
// //     //impresion sin paquete solo de PrintBluetoothTermal
// //     bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
// //     if (connectionStatus) {
// //       String text = "${_txtText.text}\n";
// //       bool result = await PrintBluetoothThermal.writeString(
// //           printText: PrintTextSize(size: int.parse(_selectSize), text: text));
// //       logger.v("status print result: $result");
// //       setState(() {
// //         _msj = "printed status: $result";
// //       });
// //     } else {
// //       //no conectado, reconecte
// //       setState(() {
// //         _msj = "no connected device";
// //       });
// //       logger.v("no conectado");
// //     }
// //   }
// // }
