import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/main.dart';
import 'package:vms_mobile_app/screens/mobile/widgets/image_box.dart';

import '../../decoration/buttons.dart';
import '../../decoration/container.dart';
import '../../decoration/dialogs.dart';
import '../../decoration/text_fields.dart';
import '../../provider/common_provider.dart';
import '../../service/api_service.dart';
import '../../utilities/color.dart';
import '../../utilities/fonts.dart';
import '../../utilities/loaders.dart';
import '../../utilities/localvariable.dart';
import '../../utilities/notifications.dart';

class UnMatchedScreen extends StatefulWidget {
  const UnMatchedScreen({super.key});

  @override
  State<UnMatchedScreen> createState() => _UnMatchedScreenState();
}

class _UnMatchedScreenState extends State<UnMatchedScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        Provider.of<CommonProvider>(context, listen: false).getUnMatched());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: 60),
        Consumer<CommonProvider>(builder: (_, provd, __) {
          return SizedBox(
            height: MediaQuery.of(context).size.height - 138,
            child: provd.unMatched.isEmpty
                ? Center(child: SizedBox(child: textBlue("No Data...")))
                : gridList(provd.unMatched),
          );
        }),
      ],
    );
  }

  Widget gridList(List list) => SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            child: ListView.builder(
                itemCount: list.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GridChildUnmatched(list: list, index: index);
                }),
          )));
}

class GridChildUnmatched extends StatefulWidget {
  const GridChildUnmatched(
      {super.key, required this.list, required this.index});
  final List list;
  final int index;

  @override
  State<GridChildUnmatched> createState() => _GridChildUnmatchedState();
}

class _GridChildUnmatchedState extends State<GridChildUnmatched> {
  TextEditingController vehicleNo = TextEditingController();
  bool loading = false;

  vehicleNumber() {
    setState(() {
      List<String> stringArray =
          widget.list[widget.index]['license_plate_number'].split("/");
      vehicleNo.text = stringArray[0];
    });
  }

  @override
  void initState() {
    vehicleNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vehicleNumber();
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 8, right: 8, left: 8),
      padding: const EdgeInsets.only(top: 8, bottom: 2, right: 2, left: 2),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
          width: context.mediaQuery.size.width,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // textBold12("Vehicle Image"),
            // const SizedBox(height: 2),
            Row(
              children: [
                ImageFrame(
                    url:
                        "${LocVar.imageUrl + widget.list[widget.index]['images']}.jpeg"),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(right: 4, left: 4, bottom: 4),
                child: Column(
                  children: [
                    Consumer<CommonProvider>(builder: (_, provd, __) {
                      DateTime date = DateFormat("yyyy-MM-dd hh:mm:ss")
                          .parse(widget.list[widget.index]['date_time']);
                      return Text(
                          "Feed Entry Time: ${DateFormat('dd MMM hh:mm a').format(date)}",
                          style: FFonts.labelStyle);
                    }),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: authField3("Vehicle no", vehicleNo, 50,
                          TextInputType.text, TextCapitalization.characters),
                    ),
                    buttonPrimary("Out", () {
                      var data = {
                        "feed_id": widget.list[widget.index]['id'].toString(),
                        "license_no": vehicleNo.text
                      };
                      setState(() => loading = true);
                      ApiService()
                          .post(context, "map_feed_to_entry", params: data)
                          .then((received) {
                        setState(() => loading = false);
                        if (received['status'] == "success") {
                          return notif('Success', received['message']);
                        } else {
                          return commonDialog(
                              context,
                              PopupSkip(
                                  license: vehicleNo.text,
                                  id: widget.list[widget.index]['id']
                                      .toString()),
                              350);
                        }
                      });
                    })
                  ],
                ),
              ),
            ),
          ])),
    );
  }
}

class PopupSkip extends StatefulWidget {
  const PopupSkip({super.key, required this.license, required this.id});
  final String license;
  final String id;

  @override
  State<PopupSkip> createState() => _PopupSkipState();
}

class _PopupSkipState extends State<PopupSkip> {
  bool loading = false;

  skip() {
    setState(() {
      loading = true;
    });
    ApiService().post(indexKey.currentContext!, "skip_feeds",
        params: {"feed_id": widget.id}).then((val) {
      setState(() {
        loading = false;
      });
      Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
          .getUnMatched();
      return Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width - 16,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: decorCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("NO ENTRY MATCHED", style: FFonts.labelStyle),
          const SizedBox(height: 12),
          textBold12("License no: ${widget.license}, not matching any entry."),
          const SizedBox(height: 12),
          loading
              ? loading50Button()
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  buttonDialogYes(context, "Skip", () => skip()),
                  const SizedBox(width: 8),
                  buttonDialogNo(context, "Cancel"),
                ]),
        ],
      ),
    );
  }
}

class PopPup extends StatefulWidget {
  const PopPup(
      {super.key, required this.id, required this.image, required this.plate});

  final int id;
  final String image;
  final String plate;

  @override
  State<PopPup> createState() => _PopPupState();
}

class _PopPupState extends State<PopPup> {
  bool outSelect = false;
  bool loading = false;
  List notReturned = [];

  getNonOut() {
    String selectedLocation =
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
            .locations[0]['location_id'];
    ApiService()
        .get(context, "no_out_time_entry/$selectedLocation")
        .then((received) {
      if (received['data'] != null && received['data'].isNotEmpty) {
        setState(() {
          notReturned = received['data'];
        });
      }
    });
  }

  setExit() {
    setState(() {
      loading = true;
    });
    ApiService()
        .get(indexKey.currentContext!, "out_entry/${widget.id}")
        .then((val) {
      setState(() {
        loading = false;
      });
      if (val != null) {
        Navigator.of(context).pop();
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
            .getUnMatched();
        return notif('Success', val['message']);
      } else {
        return;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getNonOut();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        listUnMatched(),
        const SizedBox(height: 12),
        matchButton(),
      ],
    );
  }

  int selected = 1000;
  int selectedId = 0;

  setUnmatchedCall() {
    if (selected == 1000) {
      return notif('Failed', "Select the matching field");
    }
    var data = {
      "entry_id": selectedId.toString(),
      "feed_id": widget.id.toString()
    };
    setState(() {
      loading = true;
    });
    ApiService().post(context, "map_unmatchFeeds", params: data).then((value) {
      setState(() {
        loading = true;
      });
      if (value['status'] == "success") {
        notif('Failed', "Feed mapped & checkout success.");
        Provider.of<CommonProvider>(context, listen: false).getUnMatched();
        return Navigator.of(context).pop();
      } else {
        notif('Failed', "Some technical error happened...");
        return;
      }
    });
  }

  Widget listUnMatched() => Container(
        height: 320,
        width: MediaQuery.of(context).size.width - 16,
        padding: const EdgeInsets.all(12),
        decoration: decorCard(),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: notReturned.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected = index;
                    selectedId = notReturned[index]['id'];
                  });
                },
                child: Container(
                  decoration:
                      selected == index ? decorSelected() : decorUnSelected(),
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 110,
                  width: 376,
                  child: Row(children: [
                    SizedBox(
                        height: 102,
                        width: 170,
                        child: ImageFrame(
                            url: LocVar.imageUrl +
                                notReturned[index]['images'])),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        content("Vehicle No",
                            notReturned[index]['vehicle_no'] ?? ""),
                        content("Time", notReturned[index]['in_time']),
                      ],
                    )
                  ]),
                ),
              );
            }),
      );

  Widget matchButton() => Container(
        height: 290,
        width: MediaQuery.of(context).size.width - 16,
        decoration: decorCard(),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                            textContent("Un Matched - Exit")
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: CColors.danger,
                            child: Icon(Icons.clear,
                                color: CColors.light, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    textSideBar("Kindly select the matched exit..."),
                    const SizedBox(height: 12),
                    ImageFrame(url: widget.image),
                    const SizedBox(height: 12),
                    loading
                        ? loading50Button()
                        : Column(
                            children: [
                              buttonPrimary(
                                  "Match & Out", () => setUnmatchedCall()),
                              // const SizedBox(height: 12),
                              // buttonSecondaryOutline("Close", () {
                              //   setState(() {
                              //     Navigator.of(context).pop();
                              //   });
                              // }),
                            ],
                          )
                  ],
                ),
              ),
            ]),
      );
}
