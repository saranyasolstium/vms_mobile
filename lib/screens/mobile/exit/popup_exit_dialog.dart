import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/screens/mobile/exit/visitors_screen.dart';

import '../../../decoration/buttons.dart';
import '../../../decoration/container.dart';
import '../../../main.dart';
import '../../../provider/common_provider.dart';
import '../../../service/api_service.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/loaders.dart';
import '../../../utilities/notifications.dart';
import '../widgets/image_box.dart';

class PopPup extends StatefulWidget {
  const PopPup({Key? key, required this.data, required this.index})
      : super(key: key);
  final List data;
  final int index;

  @override
  State<PopPup> createState() => _PopPupState();
}

class _PopPupState extends State<PopPup> {
  bool outSelect = false;
  bool loading = false;

  setExit() {
    setState(() {
      loading = true;
    });
    ApiService()
        .get(indexKey.currentContext!,
            "out_entry/${widget.data[widget.index]['id']}")
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: loading
          ? 280
          : outSelect
              ? 410
              : 326,
      width: 500,
      decoration: decorCard(),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin, color: CColors.light),
                      const SizedBox(width: 6),
                      textContent(widget.data[widget.index]['get_visitor']
                              ['visitor_name']
                          .toString())
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: CColors.danger,
                      child: Icon(Icons.clear, color: CColors.light, size: 18),
                    ),
                  ),
                ],
              ),
              Wrap(children: [
                content(
                    "In-Time",
                    widget.data[widget.index]['in_time'].substring(0, 10) +
                        " | " +
                        widget.data[widget.index]['in_time'].substring(11, 16)),
                widget.data[widget.index]['out_time'] == null
                    ? content("Out_time", "")
                    : content(
                        "Out-Time",
                        widget.data[widget.index]['out_time']
                            .substring(11, 16)),
              ]),
              Wrap(children: [
                content("Email-Id",
                    widget.data[widget.index]['get_visitor']['email'] ?? ""),
                content("Mobile No",
                    widget.data[widget.index]['get_visitor']['mobile'] ?? ""),
                content("Contact Person",
                    widget.data[widget.index]['contact_person'] ?? ""),
                content(
                    "Vehicle", widget.data[widget.index]['vehicle_no'] ?? ""),
              ]),
              Wrap(children: [
                content("Role", widget.data[widget.index]['role'] ?? ""),
                widget.data[widget.index]['visit_reason'] == null
                    ? content("purpose", "")
                    : content(
                        "Purpose",
                        widget.data[widget.index]['visit_reason']["purpose"] ??
                            ""),
              ]),
              const SizedBox(height: 12),
              loading
                  ? loading50Button()
                  : outSelect
                      ? Column(
                          children: [
                            textDesc(
                                "Are you sure he is out? ${DateTime.now()}"),
                            buttonPrimary("Yes", () => setExit()),
                            const SizedBox(height: 12),
                            buttonSecondaryOutline("Close", () {
                              setState(() {
                                outSelect = false;
                              });
                            }),
                          ],
                        )
                      : buttonPrimary("OUT", () {
                          setState(() {
                            outSelect = true;
                          });
                        }),
            ],
          ),
        ),
      ]),
    );
  }
}
