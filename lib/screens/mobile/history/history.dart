import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/container.dart';

import '../../../decoration/text_fields.dart';
import '../../../main.dart';
import '../../../provider/common_provider.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/loaders.dart';
import '../exit/visitor_grids.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  int type = 1;
  String search = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 250), () {
      return Provider.of<CommonProvider>(indexKey.currentContext!,
              listen: false)
          .getHistory(type, search);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<CommonProvider>(context, listen: false).addHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          // const SizedBox(height: 64),
          SizedBox(
            width: MediaQuery.of(context).size.width - 16,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  inputFormatters: [UpperCaseTextFormatter()],
                  cursorColor: CColors.shade1,
                  cursorHeight: 24,
                  onChanged: (val) => Provider.of<CommonProvider>(
                          indexKey.currentContext!,
                          listen: false)
                      .getHistory(type, val),
                  style: FFonts.formFont,
                  decoration: InputDecoration(
                    label: const Text("Search"),
                    labelStyle: FFonts.labelStyle,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: const EdgeInsets.only(left: 18),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(width: 1, color: CColors.shade1)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(width: 1, color: CColors.shade1)),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: size.width - 8,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: decorCard(),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    type = 1;
                    Provider.of<CommonProvider>(indexKey.currentContext!,
                            listen: false)
                        .getHistory(type, search);
                  }),
                  child: Container(
                    height: 50,
                    width: size.width / 2 - 8,
                    decoration: type == 1 ? decorSelected() : decorUnSelected(),
                    padding: const EdgeInsets.all(0),
                    child: Center(child: textSideHeading("Visitor Entry")),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    type = 2;
                    Provider.of<CommonProvider>(indexKey.currentContext!,
                            listen: false)
                        .getHistory(type, search);
                  }),
                  child: Container(
                    height: 50,
                    width: size.width / 2 - 8,
                    decoration: type == 1 ? decorUnSelected() : decorSelected(),
                    padding: const EdgeInsets.all(0),
                    child: Center(child: textSideHeading("WalkIn Entry")),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Consumer<CommonProvider>(builder: (_, provd, __) {
                return provd.listHistory.isEmpty
                    ? textBlue("Seems like no visitor!")
                    : SizedBox(
                        height: MediaQuery.of(context).size.height - 290,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: gridList(),
                        ));
              }),
            ),
          ),
          Consumer<CommonProvider>(builder: (_, provd, __) {
            return provd.commonLoading ? loading50Button() : const SizedBox();
          }),
          const SizedBox(height: 84)
        ],
      ),
    );
  }

  Widget gridList() => Consumer<CommonProvider>(builder: (_, provd, __) {
        return provd.listHistory.isEmpty
            ? const SizedBox()
            : ListView.builder(
                itemCount: provd.listHistory.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return ExitGrid(data: provd.listHistory, index: index);
                });
      });
}
