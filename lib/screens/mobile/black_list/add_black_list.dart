import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/buttons.dart';
import 'package:vms_mobile_app/decoration/text_fields.dart';
import 'package:vms_mobile_app/provider/black_list_provider.dart';
import 'package:vms_mobile_app/utilities/color.dart';
import 'package:vms_mobile_app/utilities/fonts.dart';
import 'package:vms_mobile_app/utilities/loaders.dart';

import '../../../main.dart';
import '/utilities/notifications.dart';

class AddBlackList extends StatefulWidget {
  const AddBlackList({Key? key}) : super(key: key);

  @override
  State<AddBlackList> createState() => _AddBlackListState();
}

class _AddBlackListState extends State<AddBlackList> {
  final TextEditingController blackVehicle = TextEditingController();
  final TextEditingController blackMobile = TextEditingController();
  final TextEditingController blackVehicleReason = TextEditingController();
  final TextEditingController blackMobilereason = TextEditingController();

  @override
  void dispose() {
    blackVehicle.dispose();
    blackMobile.dispose();
    super.dispose();
  }

  void _submit(int tabIndex) {
    final provider = Provider.of<BlackListProvider>(
      indexKey.currentContext!,
      listen: false,
    );

    if (tabIndex == 0) {
      // Vehicle
      final v = blackVehicle.text.trim();
      if (v.length >= 5) {
        provider.addBlackList(
            context,
            v,
            "vehicle",
            blackVehicleReason.text
                .toString()
                .trim()); // adjust signature if needed
      } else {
        notif("", "Kindly check vehicle number.");
      }
    } else {
      // Mobile
      final m = blackMobile.text.trim();
      if (m.length >= 5) {
        provider.addBlackList(
            context,
            m,
            "mobile",
            blackMobilereason.text
                .toString()
                .trim()); // adjust signature if needed
      } else {
        notif("", "Kindly check mobile number.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0, // Vehicle first
      child: Container(
        width: 380,
        height: 340,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: CColors.dark),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: textSideHeading(
                      "Add to Blacklist",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.clear, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Simple text-only tabs like your screenshot
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  dividerColor: Colors.black,
                  tabBarTheme: const TabBarTheme(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    unselectedLabelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                child: const TabBar(
                  isScrollable: true,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2.0, color: Colors.black),
                    insets: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black26,
                  tabs: [
                    Tab(text: "Vehicle"),
                    Tab(text: "Mobile"),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    // Vehicle input
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          authField("Vehicle Number", blackVehicle, 50,
                              TextInputType.text, TextCapitalization.words),
                          authField("Reason", blackVehicleReason, 50,
                              TextInputType.text, TextCapitalization.words),
                        ],
                      ),
                    ),

                    // Mobile input
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          authField("Mobile Number", blackMobile, 50,
                              TextInputType.text, TextCapitalization.words),
                          authField("Reason", blackMobilereason, 50,
                              TextInputType.text, TextCapitalization.words),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Save button (wrapped in Builder to get the inner context)
              Builder(
                builder: (innerCtx) {
                  return Consumer<BlackListProvider>(
                    builder: (_, provider, __) {
                      return provider.blackListLoading
                          ? loading50Button()
                          : buttonPrimary("Save", () {
                              final idx =
                                  DefaultTabController.of(innerCtx).index;
                              _submit(idx);
                            });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../main.dart';
// import '/provider/black_list_provider.dart';
// import '/utilities/notifications.dart';
// import '../../../decorations/buttons.dart';
// import '../../../decorations/text_fields.dart';
// import '../../../universals/loaders.dart';
// import '../../../utilities/colors.dart';
// import '../../../utilities/fonts.dart';

// class AddBlackList extends StatefulWidget {
//   const AddBlackList({Key? key}) : super(key: key);

//   @override
//   State<AddBlackList> createState() => _AddBlackListState();
// }

// class _AddBlackListState extends State<AddBlackList> {
//   TextEditingController blackVehicle = TextEditingController();

//   addBlackList(){
//     if(blackVehicle.text.length >= 5 ){
//       return Provider.of<BlackListProvider>(indexKey.currentContext!, listen: false).addBlackList(context, blackVehicle.text);
//     }else{
//       return failMessage("Kindly check vehicle number.");
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 380,
//       height: 210,
//       decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: CColors.dark),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 text18("Add Vehicle to Blacklist"),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const CircleAvatar(
//                     radius: 12,
//                     backgroundColor: CColors.danger,
//                     child: Icon(Icons.clear, color: CColors.light, size: 18),
//                   ),
//                 )
//               ],
//             ),
//             const SizedBox(height: 32),
//             authField("Vehicle Number", blackVehicle),
//             Consumer<BlackListProvider>(builder: (_,provider,__){
//               return provider.blackListLoading ? loading50Button() : buttonPrimary("Save", () => addBlackList());
//             }),


//           ],
//         ),
//       ),
//     );
//   }
// }
