import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/container.dart';
import 'package:vms_mobile_app/decoration/dialogs.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/screens/mobile/widgets/image_box.dart';
import 'package:vms_mobile_app/utilities/color.dart';
import '/provider/black_list_provider.dart';
import '../../../main.dart';
import '../../../provider/common_provider.dart';
import '../../../utilities/fonts.dart';
import 'add_black_list.dart';
import 'delete_black_list.dart';
import 'edit_black_list.dart';

class BlockList extends StatefulWidget {
  const BlockList({Key? key}) : super(key: key);

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
          .loadingOff();
      Provider.of<BlackListProvider>(indexKey.currentContext!, listen: false)
          .getBlockList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        const Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Divider(thickness: 2, height: 36, color: CColors.shade1),
        ),
        blackList()
      ],
    );
  }

  Widget blackList() => SizedBox(
        height: MediaQuery.of(context).size.height - 209,
        width: MediaQuery.of(context).size.width,
        child: Consumer<BlackListProvider>(
          builder: (_, provider, __) {
            return provider.blackList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 32, left: 5, right: 5),
                    child: textSideHeading("May be there is no data!"),
                  )
                : ListView.builder(
                    itemCount: provider.blackList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = provider.blackList[index];
                      final date = DateFormat("yyyy-MM-dd hh:mm:ss")
                          .parse(item['Created_at']);

                      final personName =
                          (item['visitor_name']?.toString().isEmpty ?? true)
                              ? 'N/A'
                              : item['visitor_name'].toString();
                      final mobile = item['mobile_no']?.toString() ?? '—';
                      final vehicle = item['vehicle_no']?.toString() ?? '—';
                      final reason = item['block_reason']?.toString() ?? '—';
                      final when = DateFormat('dd MMM hh:mm a').format(date);

                      return Card(
                        elevation: 2,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT: text section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Person + Mobile Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: _pair(Icons.person_outline,
                                                'Person Name', personName,
                                                bold: true)),
                                        Expanded(
                                            child: _pair(Icons.phone_outlined,
                                                'Mobile No', mobile,
                                                bold: true)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _pair(
                                              Icons.directions_car_outlined,
                                              'Vehicle No',
                                              vehicle,
                                              bold: true),
                                        ),
                                        Expanded(
                                          child: _pair(Icons.info_outline,
                                              'Reason', reason,
                                              bold: true),
                                        ),
                                      ],
                                    ),
                                    // Black Listed On
                                    _pair(Icons.access_time, 'Black Listed On',
                                        when),
                                  ],
                                ),
                              ),

                              // RIGHT: Action Buttons
                              Column(
                                children: [
                                  _circleAction(
                                    icon: Icons.edit_outlined,
                                    iconColor: Colors.green,
                                    bgColor: Colors.green.withOpacity(0.1),
                                    onTap: () => commonDialog(
                                      context,
                                      EditBlackList(
                                        id: item['id'].toString(),
                                        vehicle: item['vehicle_no'] ??
                                            item['mobile_no'],
                                        type: item['type'].toString(),
                                        reason: item['block_reason'] ?? "",
                                      ),
                                      300,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _circleAction(
                                    icon: Icons.delete_outline,
                                    iconColor: Colors.red,
                                    bgColor: Colors.red.withOpacity(0.1),
                                    onTap: () => commonDialog(
                                      context,
                                      DeleteBlackList(
                                          id: item['id'].toString()),
                                      300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

            // ListView.builder(
            //     itemCount: provider.blackList.length,
            //     shrinkWrap: true,
            //     itemBuilder: (context, index) {
            //       DateTime date = DateFormat("yyyy-MM-dd hh:mm:ss")
            //           .parse(provider.blackList[index]['Created_at']);
            //       return Container(
            //         decoration: decorUnSelected(),
            //         margin: const EdgeInsets.only(
            //             bottom: 12, left: 5, right: 5),
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 12, vertical: 2),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             content(
            //                 "Visitor Name",
            //                 provider.blackList[index]['visitor_name'] ??
            //                     ""),
            //             content("Vehicle Number",
            //                 provider.blackList[index]['vehicle_no'] ?? ""),
            //             content("Mobile Number",
            //                 provider.blackList[index]['mobile_no'] ?? ""),
            //             content(
            //                 "reason",
            //                 provider.blackList[index]['block_reason'] ??
            //                     ""),
            //             content(
            //                 "Black Listed On",
            //                 DateFormat('dd MMM hh:mm a')
            //                     .format(date)
            //                     .toString()),
            //             Row(
            //               children: [
            //                 CircleAvatar(
            //                     radius: 20,
            //                     backgroundColor: CColors.dark,
            //                     child: IconButton(
            //                         onPressed: () => commonDialog(
            //                             context,
            //                             EditBlackList(
            //                               id: provider.blackList[index]
            //                                       ['id']
            //                                   .toString(),
            //                               vehicle: provider.blackList[index]
            //                                       ['vehicle_no'] ??
            //                                   provider.blackList[index]
            //                                       ['mobile_no'],
            //                               type: provider.blackList[index]
            //                                       ['type']
            //                                   .toString(),
            //                               reason: provider.blackList[index]
            //                                       ["block_reason"] ??
            //                                   "",
            //                             ),
            //                             300),
            //                         icon: const Icon(Icons.edit_outlined,
            //                             color: CColors.success, size: 20))),
            //                 const SizedBox(width: 8),
            //                 CircleAvatar(
            //                     radius: 20,
            //                     backgroundColor: CColors.dark,
            //                     child: IconButton(
            //                         onPressed: () => commonDialog(
            //                             context,
            //                             DeleteBlackList(
            //                                 id: provider.blackList[index]
            //                                         ['id']
            //                                     .toString()),
            //                             300),
            //                         icon: const Icon(Icons.delete_outline,
            //                             color: CColors.danger, size: 20)))
            //               ],
            //             )
            //           ],
            //         ),
            //       );
            //     });
          },
        ),
      );

  Widget _pair(IconData icon, String label, String value, {bool bold = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400)),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget header() => Padding(
        padding:
            const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buttonAddUser("+ Blacklist",
                () => commonDialog(context, const AddBlackList(), 500)),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 50,
              width: 220,
              child: TextFormField(
                cursorColor: CColors.shade1,
                onChanged: (value) => Provider.of<BlackListProvider>(
                        indexKey.currentContext!,
                        listen: false)
                    .searchBlockList(value),
                cursorHeight: 24,
                style: FFonts.formFont,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  hintText: "Search here",
                  hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w200),
                  labelStyle: FFonts.labelStyle,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: const EdgeInsets.only(left: 18),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(width: 0.1, color: CColors.light)),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(width: 1, color: CColors.shade1)),
                ),
              ),
            ),
          ],
        ),
      );
}
