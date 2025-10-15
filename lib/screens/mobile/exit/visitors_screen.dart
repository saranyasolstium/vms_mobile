import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/main.dart';
import 'package:vms_mobile_app/screens/mobile/exit/visitor_grids.dart';

import '../../../decoration/container.dart';
import '../../../provider/common_provider.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/loaders.dart';

int typeNotReturned = 1;

class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
            .getNotReturned(typeNotReturned));
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<CommonProvider>(context, listen: false).addNotReturned();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height - 50,
      width: size.width,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // searchAllScreen(context),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      typeNotReturned = 1;
                      Provider.of<CommonProvider>(indexKey.currentContext!,
                              listen: false)
                          .getNotReturned(typeNotReturned);
                    }),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 14,
                      decoration: typeNotReturned == 1
                          ? decorSelected()
                          : decorUnSelected(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Center(child: textSideHeading("Visitor Entry")),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() {
                      typeNotReturned = 2;
                      Provider.of<CommonProvider>(indexKey.currentContext!,
                              listen: false)
                          .getNotReturned(typeNotReturned);
                    }),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 14,
                      decoration: typeNotReturned == 1
                          ? decorUnSelected()
                          : decorSelected(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  return provd.feedNotReturned.isEmpty
                      ? textBlue("Seems like no visitor!")
                      : SizedBox(
                          height: MediaQuery.of(context).size.height - 145,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: gridList(),
                          ));
                }),
              ),
            ),
            Consumer<CommonProvider>(builder: (_, provd, __) {
              return provd.notReturnedLoad
                  ? loading50Button()
                  : const SizedBox();
            }),
            const SizedBox(height: 84)
          ],
        ),
      ),
    );
  }

  Widget gridList() => Consumer<CommonProvider>(builder: (_, provd, __) {
        return provd.feedNotReturned.isEmpty
            ? const SizedBox()
            : ListView.builder(
                itemCount: provd.feedNotReturned.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return ExitGrid(data: provd.feedNotReturned, index: index);
                });
      });
}
