import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/main.dart';
import 'package:vms_mobile_app/screens/mobile/exit/visitors_screen.dart';
import 'package:vms_mobile_app/utilities/localvariable.dart';
import '../../../decoration/buttons.dart';
import '../../../decoration/dialogs.dart';
import '../../../provider/common_provider.dart';
import '../../../service/api_service.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/loaders.dart';
import '../../../utilities/notifications.dart';
import '../widgets/image_box.dart';

class ExitGrid extends StatefulWidget {
  const ExitGrid({super.key, required this.data, required this.index});
  final List data;
  final int index;

  @override
  State<ExitGrid> createState() => _ExitGridState();
}

class _ExitGridState extends State<ExitGrid> {
  int differenceMinutes = 0;
  int exitDifferenceMinutes = 0;
  DateTime entryTime = DateTime.now();
  DateTime exitTime = DateTime.now();
  DateTime now = DateTime.now();

// --- conversions ---
  DateTime _sgStringToUtc(String s) {
    // s is SG local time (UTC+8). Convert to UTC safely.
    final p = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(s);
    return DateTime.utc(p.year, p.month, p.day, p.hour, p.minute, p.second)
        .subtract(const Duration(hours: 8));
  }

  DateTime _sgStringToDisplay(String s) {
    final p = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(s);
    return DateTime(p.year, p.month, p.day, p.hour, p.minute, p.second);
  }

  void timeCalculation() {
    final item = widget.data[widget.index];

    // Entry
    final inStr = (item['in_time'] ?? '').toString().trim();
    final entryUtc = _sgStringToUtc(inStr);
    entryTime = _sgStringToDisplay(inStr);

    final outRaw = item['out_time'];
    if (outRaw != null && outRaw.toString().trim().isNotEmpty) {
      // Exit path
      final outStr = outRaw.toString().trim();
      final exitUtc = _sgStringToUtc(outStr);
      exitTime = _sgStringToDisplay(outStr);

      final secs = exitUtc.difference(entryUtc).inSeconds;
      // ceil to minutes; never negative
      exitDifferenceMinutes = secs <= 0 ? 0 : ((secs + 59) ~/ 60);
      differenceMinutes = 0; // not used in exit path
    } else {
      // Still inside
      final nowUtc = DateTime.now().toUtc();
      final secs = nowUtc.difference(entryUtc).inSeconds;
      differenceMinutes = secs <= 0 ? 0 : ((secs + 59) ~/ 60);
      exitDifferenceMinutes = 0;
    }
  }

  String timeElapsed2 = "-";
  int hour = 00;
  int minutes = 00;
  int hours = 00;
  int days = 00;

  differenceFormattedString(int minute) {
    setState(() {
      hour = minute ~/ 60;
      minutes = minute % 60;
      hours = hour % 24;
      days = hour ~/ 24;
    });
  }

  @override
  Widget build(BuildContext context) {
    timeCalculation();
    widget.data[widget.index]['out_time'] == null
        ? differenceFormattedString(differenceMinutes)
        : differenceFormattedString(exitDifferenceMinutes);
    final currentLocationId =
        Provider.of<CommonProvider>(context, listen: false).locations[
            Provider.of<CommonProvider>(context, listen: false)
                .selectedLocation]['location_id'];
    return GestureDetector(
      onTap: () => commonDialog(
          indexKey.currentContext!,
          PopPup(
              data: widget.data,
              index: widget.index,
              button:
                  widget.data[widget.index]['out_time'] != null ? false : true),
          200),
      child: Container(
        width: 450,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: widget.data[widget.index]['out_time'] == null
              ? differenceMinutes <= 30
                  ? Colors.lightGreen
                  : CColors.danger
              : CColors.shade1,
        ),
        child: Padding(
            padding:
                const EdgeInsets.only(top: 6, right: 2, left: 2, bottom: 2),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: CColors.dark),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin, color: CColors.light),
                            const SizedBox(width: 6),
                            textContent(widget.data[widget.index]['get_visitor']
                                    ['visitor_name'] ??
                                "-")
                          ],
                        ),
                        Wrap(children: [
                          // content("Vehicle", widget.data[widget.index]['vehicle_no'] ?? ""),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: content(
                                  "In-Time",
                                  DateFormat('dd MMM hh:mm a')
                                      .format(entryTime)
                                      .toString())),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child:
                                  widget.data[widget.index]['out_time'] == null
                                      ? content("Out-Time", "")
                                      : content(
                                          "Out-Time",
                                          DateFormat('dd MMM hh:mm a')
                                              .format(exitTime)
                                              .toString())),
                        ]),
                        Wrap(children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: content(
                                  "Mobile No",
                                  widget.data[widget.index]['get_visitor']
                                          ['mobile'] ??
                                      "")),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: widget.data[widget.index]
                                          ['visit_reason'] ==
                                      null
                                  ? content("purpose", "")
                                  : content(
                                      "Purpose",
                                      widget.data[widget.index]['visit_reason']
                                              ["purpose"] ??
                                          "")),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content(
                                currentLocationId == "64f1d7a46fbcc7432ee4889c"
                                    ? "Purpose of Contractor"
                                    : "Contact Person",
                                widget.data[widget.index]['contact_person'] ??
                                    "NA"),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content("Unit No.",
                                widget.data[widget.index]['unit_no'] ?? ""),
                          ),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content("Vehicle",
                                widget.data[widget.index]['vehicle_no'] ?? ""),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: widget.data[widget.index]['out_time'] != null
                                ? timeElapsed(exitDifferenceMinutes.toString())
                                : timeElapsed(differenceMinutes.toString()),
                          ),
                        ]),
                      ]),
                  widget.data[widget.index]['out_time'] == null
                      ? Positioned(
                          right: 4,
                          top: 0,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => commonDialog(
                                    context,
                                    PopPup(
                                        data: widget.data,
                                        index: widget.index,
                                        button: true),
                                    200),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              color: CColors.brand1,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Icon(Icons.delete,
                                              color: CColors.dark, size: 12)),
                                      const SizedBox(width: 6),
                                      textBlue("OUT")
                                    ]),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            )),
      ),
    );
  }

  Widget timeElapsed(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        textShade("Total Time"),
        Row(
          children: [
            days != 00
                ? Text("$days Day",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: CColors.light,
                        letterSpacing: 0.25))
                : const SizedBox(),
            hours != 00
                ? Text(" $hours Hr",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: CColors.light,
                        letterSpacing: 0.25))
                : const SizedBox(),
            Text(" $minutes Min",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: CColors.light,
                    letterSpacing: 0.25))
          ],
        )
      ]),
    );
  }
}

class PopPup extends StatefulWidget {
  const PopPup(
      {Key? key, required this.data, required this.index, required this.button})
      : super(key: key);
  final List data;
  final int index;
  final bool button;

  @override
  State<PopPup> createState() => _PopPupState();
}

class _PopPupState extends State<PopPup> {
  bool outSelect = true;
  bool loading = false;

  setExit() {
    setState(() {
      loading = true;
    });
    ApiService()
        .get(indexKey.currentContext!,
            "out_entry/${widget.data[widget.index]['id']}/${reasonControl.text}")
        .then((val) {
      setState(() {
        loading = false;
      });
      if (val != null) {
        Navigator.of(context).pop();
        Provider.of<CommonProvider>(context, listen: false)
            .getNotReturned(typeNotReturned);
        return notif('Succ', val['message']);
      } else {
        return;
      }
    });
  }

  setBlockExit() {
    setState(() {
      loading = true;
    });
    ApiService()
        .get(indexKey.currentContext!,
            "out_block/${widget.data[widget.index]['id']}/${reasonControl.text}")
        .then((val) {
      setState(() {
        loading = false;
      });
      if (val != null) {
        Navigator.of(context).pop();
        Provider.of<CommonProvider>(context, listen: false)
            .getNotReturned(typeNotReturned);
        return notif('Success', val['message']);
      } else {
        return;
      }
    });
  }

  int differenceMinutes = 0;
  int exitDifferenceMinutes = 0;

  DateTime entryTime = DateTime.now();
  DateTime exitTime = DateTime.now();
  DateTime now = DateTime.now();
  // --- conversions ---
  DateTime _sgStringToUtc(String s) {
    // s is SG local time (UTC+8). Convert to UTC safely.
    final p = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(s);
    return DateTime.utc(p.year, p.month, p.day, p.hour, p.minute, p.second)
        .subtract(const Duration(hours: 8));
  }

  DateTime _sgStringToDisplay(String s) {
    final p = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(s);
    return DateTime(p.year, p.month, p.day, p.hour, p.minute, p.second);
  }

  void timeCalculation() {
    final item = widget.data[widget.index];

    // Entry
    final inStr = (item['in_time'] ?? '').toString().trim();
    final entryUtc = _sgStringToUtc(inStr);
    entryTime = _sgStringToDisplay(inStr);

    final outRaw = item['out_time'];
    if (outRaw != null && outRaw.toString().trim().isNotEmpty) {
      // Exit path
      final outStr = outRaw.toString().trim();
      final exitUtc = _sgStringToUtc(outStr);
      exitTime = _sgStringToDisplay(outStr);

      final secs = exitUtc.difference(entryUtc).inSeconds;
      // ceil to minutes; never negative
      exitDifferenceMinutes = secs <= 0 ? 0 : ((secs + 59) ~/ 60);
      differenceMinutes = 0; // not used in exit path
    } else {
      // Still inside
      final nowUtc = DateTime.now().toUtc();
      final secs = nowUtc.difference(entryUtc).inSeconds;
      differenceMinutes = secs <= 0 ? 0 : ((secs + 59) ~/ 60);
      exitDifferenceMinutes = 0;
    }
  }

  int hour = 00;
  int minutes = 00;
  int hours = 00;
  int days = 00;
  differenceFormattedString(int minute) {
    setState(() {
      hour = minute ~/ 60;
      minutes = minute % 60;
      hours = hour % 24;
      days = hour ~/ 24;
    });
  }

  @override
  Widget build(BuildContext context) {
    timeCalculation();
    widget.data[widget.index]['out_time'] == null
        ? differenceFormattedString(differenceMinutes)
        : differenceFormattedString(exitDifferenceMinutes);
    final currentLocationId =
        Provider.of<CommonProvider>(context, listen: false).locations[
            Provider.of<CommonProvider>(context, listen: false)
                .selectedLocation]['location_id'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: widget.data[widget.index]['out_time'] == null
                  ? differenceMinutes <= 30
                      ? Colors.lightGreen
                      : CColors.danger
                  : CColors.shade1,
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.only(top: 6, right: 2, left: 2, bottom: 2),
          margin: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: CColors.dark),
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_pin,
                                    color: CColors.light),
                                const SizedBox(width: 6),
                                textContent(widget.data[widget.index]
                                        ['get_visitor']['visitor_name'] ??
                                    "-")
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: CColors.brand1,
                                child: Icon(Icons.clear,
                                    color: CColors.dark, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        widget.data[widget.index]['entry_feed'] != null
                            ? ImageFrame(
                                url:
                                    "${LocVar.imageUrl + widget.data[widget.index]['entry_feed']['images']}.jpeg")
                            : const SizedBox(),
                        widget.data[widget.index]['capture_image'] != null
                            ? ImageFrame(
                                url: LocVar.imageUrl +
                                    widget.data[widget.index]['capture_image'])
                            : const SizedBox(),
                        const SizedBox(height: 8),
                        Wrap(children: [
                          // content("Vehicle", widget.data[widget.index]['vehicle_no'] ?? ""),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: content(
                                  "In-Time",
                                  DateFormat('dd MMM hh:mm a')
                                      .format(entryTime)
                                      .toString())),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child:
                                  widget.data[widget.index]['out_time'] == null
                                      ? content("Out-Time", "")
                                      : content(
                                          "Exit Time",
                                          DateFormat('dd MMM hh:mm a')
                                              .format(exitTime)
                                              .toString()))
                        ]),
                        Wrap(children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: content(
                                  "Mobile No",
                                  widget.data[widget.index]['get_visitor']
                                          ['mobile'] ??
                                      "")),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: widget.data[widget.index]
                                          ['visit_reason'] ==
                                      null
                                  ? content("purpose", "")
                                  : content(
                                      "Purpose",
                                      widget.data[widget.index]['visit_reason']
                                              ["purpose"] ??
                                          "")),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content(
                                currentLocationId == "64f1d7a46fbcc7432ee4889c"
                                    ? "Purpose of Contractor"
                                    : "Contact Person",
                                widget.data[widget.index]['contact_person'] ??
                                    "NA"),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content("Unit No.",
                                widget.data[widget.index]['unit_no'] ?? ""),
                          ),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: content("Vehicle",
                                widget.data[widget.index]['vehicle_no'] ?? ""),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: widget.data[widget.index]['out_time'] != null
                                ? timeElapsed(Colors.white)
                                : timeElapsed(CColors.danger),
                          ),
                        ]),
                        Wrap(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 32,
                            child: content(
                                "Delay Reason",
                                widget.data[widget.index]['delay_reason'] ??
                                    ""),
                          ),
                        ]),
                        Wrap(children: [
                          content(
                              "Email-Id",
                              widget.data[widget.index]['get_visitor']
                                      ['email'] ??
                                  ""),
                        ]),
                        widget.button
                            ? const SizedBox(height: 8)
                            : const SizedBox(),
                        widget.button
                            ? authParagraph(
                                "Reason / Comment",
                                reasonControl,
                                TextInputType.text,
                                TextCapitalization.sentences)
                            : const SizedBox(),
                        widget.button
                            ? loading
                                ? loading50Button()
                                : outSelect
                                    ? Column(children: [
                                        buttonPrimary("OUT", () {
                                          setState(() {
                                            outSelect = false;
                                            blockList = false;
                                          });
                                        }),
                                        const SizedBox(height: 8),
                                        widget.data[widget.index]
                                                    ['vehicle_no'] !=
                                                null
                                            ? buttonSecondaryOutline(
                                                "Vehicle Black List & Out", () {
                                                setState(() {
                                                  outSelect = false;
                                                  blockList = true;
                                                });
                                              })
                                            : buttonSecondaryOutline(
                                                "User Black List & Out", () {
                                                setState(() {
                                                  outSelect = false;
                                                  blockList = true;
                                                });
                                              })
                                      ])
                                    : blockList
                                        ? Column(
                                            children: [
                                              textDesc(
                                                  "Block & out? ${DateTime.now()}"),
                                              buttonPrimary("Block",
                                                  () => setBlockExit()),
                                              const SizedBox(height: 12),
                                              buttonSecondaryOutline("Close",
                                                  () {
                                                setState(() {
                                                  outSelect = true;
                                                });
                                              }),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              textDesc(
                                                  "Are you sure he is out? ${DateTime.now()}"),
                                              buttonPrimary(
                                                  "Yes", () => setExit()),
                                              const SizedBox(height: 12),
                                              buttonSecondaryOutline("Close",
                                                  () {
                                                setState(() {
                                                  outSelect = true;
                                                });
                                              }),
                                            ],
                                          )
                            : const SizedBox()
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  bool blockList = false;
  TextEditingController reasonControl = TextEditingController(text: " ");

  Widget timeElapsed(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        textShade("Total Time"),
        Row(
          children: [
            days != 00
                ? Text("$days Day",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: color,
                        letterSpacing: 0.25))
                : const SizedBox(),
            hours != 00
                ? Text(" $hours Hours",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: color,
                        letterSpacing: 0.25))
                : const SizedBox(),
            Text(" $minutes Min",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: color,
                    letterSpacing: 0.25))
          ],
        )
      ]),
    );
  }
}
