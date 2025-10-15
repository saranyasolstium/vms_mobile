import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/buttons.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/utilities/color.dart';
import 'package:vms_mobile_app/utilities/loaders.dart';
import '/provider/black_list_provider.dart';
import '../../../main.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/notifications.dart';

class EditBlackList extends StatefulWidget {
  const EditBlackList(
      {super.key,
      required this.id,
      required this.vehicle,
      required this.type,
      required this.reason});
  final String id;
  final String vehicle;
  final String type;
  final String reason;

  @override
  State<EditBlackList> createState() => _EditBlackListState();
}

class _EditBlackListState extends State<EditBlackList> {
  TextEditingController blackVehicle = TextEditingController();
  TextEditingController blackReason = TextEditingController();

  editBlackList() {
    if (blackVehicle.text.length >= 5) {
      return Provider.of<BlackListProvider>(indexKey.currentContext!,
              listen: false)
          .editBlackList(widget.id, blackVehicle.text, widget.type,
              blackReason.text.toString().trim(), context);
    } else {
      return notif(
          "",
          widget.type == "mobile"
              ? "Kindly check mobile number."
              : "Kindly check vehicle number.");
    }
  }

  @override
  void initState() {
    setState(() {
      blackVehicle.text = widget.vehicle;
      blackReason.text = widget.reason;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 320,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: CColors.dark),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text18(widget.type == "mobile"
                    ? "Edit Mobile to Blacklist"
                    : "Edit Vehicle to Blacklist"),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: CColors.danger,
                    child: Icon(Icons.clear, color: CColors.light, size: 18),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            authField(
                widget.type == "mobile" ? "Mobile Number" : "Vehicle Number",
                blackVehicle,
                50,
                TextInputType.text,
                TextCapitalization.words),
            authField("Reason", blackReason, 50, TextInputType.text,
                TextCapitalization.words),
            Consumer<BlackListProvider>(builder: (_, provider, __) {
              return provider.blackListLoading
                  ? loading50Button()
                  : buttonPrimary("Save", () => editBlackList());
            }),
          ],
        ),
      ),
    );
  }
}
