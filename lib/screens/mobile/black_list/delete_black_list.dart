import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/buttons.dart';
import 'package:vms_mobile_app/decoration/container.dart';
import 'package:vms_mobile_app/utilities/loaders.dart';
import '/provider/black_list_provider.dart';
import '../../../main.dart';
import '../../../utilities/fonts.dart';

class DeleteBlackList extends StatefulWidget {
  const DeleteBlackList({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<DeleteBlackList> createState() => _DeleteBlackListState();
}

class _DeleteBlackListState extends State<DeleteBlackList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: decorCard(),
        height: 180,
        width: MediaQuery.of(context).size.width - 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 12),
            textHeading("Delete Blacklist Vehicle"),
            const SizedBox(height: 8),
            textProfile("Sure you want to delete this vehicle from blacklist"),
            const SizedBox(height: 16),
            Consumer<BlackListProvider>(builder: (_, provider, __) {
              return provider.blackListLoading
                  ? loading50Button()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buttonDialogYes(
                          context, // ✅ pass BuildContext
                          "Delete", // ✅ button label
                          () {
                            Provider.of<BlackListProvider>(
                              indexKey.currentContext!,
                              listen: false,
                            ).deleteBlackList(context, widget.id);
                          }, // ✅ onPressed callback
                        ),
                        const SizedBox(width: 8),
                        buttonDialogNo(context, "Cancel"),
                      ],
                    );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
