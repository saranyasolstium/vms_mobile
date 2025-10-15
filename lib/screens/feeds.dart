import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../provider/common_provider.dart';
import '../decoration/container.dart';
import '../utilities/color.dart';
import '../utilities/fonts.dart';
import '../utilities/loaders.dart';
import '../utilities/localvariable.dart';

class FeedList extends StatefulWidget {
  const FeedList({Key? key}) : super(key: key);

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        Provider.of<CommonProvider>(context, listen: false).addEntryFeeds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommonProvider>(builder: (_, provd, __) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 100,
        decoration: decorCard3(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textBlue24("Feeds"),
              GestureDetector(
                  onTap: () => Provider.of<CommonProvider>(context, listen: false).getEntryFeed(),
                  child: const Icon(Icons.refresh, color: CColors.brand1, size: 22))
            ],
          ),
          const SizedBox(height: 12),
          Consumer<CommonProvider>(builder: (_, provd, __) {
            return SizedBox(
              height: provd.commonLoading ? MediaQuery.of(context).size.height - 230 : MediaQuery.of(context).size.height - 180,
              child: ListView.builder(
                  itemCount: provd.feeds.length,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    List<String> stringArray = [];
                    if (provd.feeds[index]['license_plate_number'] != null) {
                      stringArray = provd.feeds[index]['license_plate_number'].split("/");
                    }
                    return Consumer<CommonProvider>(builder: (_, provdd, __) {
                      DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(provd.feeds[index]['date_time']);
                      return GestureDetector(
                        onTap: () => Provider.of<CommonProvider>(context, listen: false).setFeedIndex(index),
                        child: Container(
                          decoration: provdd.feedIndex == index
                              ? BoxDecoration(
                                  border: Border.all(width: 2, color: CColors.brand1),
                                  color: CColors.dark,
                                  borderRadius: const BorderRadius.all(Radius.circular(12)))
                              : const BoxDecoration(color: CColors.appbar, borderRadius: BorderRadius.all(Radius.circular(12))),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            child: Container(
                                height: 75,
                                width: 268,
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: CColors.dark, borderRadius: BorderRadius.all(Radius.circular(8))),
                                child: Row(children: [
                                  provd.feeds[index]['images'] != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                                          child: SizedBox(
                                            width: 75,
                                            height: 75,
                                            child: CachedNetworkImage(
                                              imageUrl: "${LocVar.imageUrl + provd.feeds[index]['images']}.jpeg",
                                              placeholder: (context, url) => Image.asset("assets/images/placeholder.png"),
                                              imageBuilder: (context, imageProvider) => Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Image.asset("assets/images/placeholder.png"),
                                            ),
                                          ))
                                      : ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                                          child: SizedBox(
                                            width: 75,
                                            height: 75,
                                            child: Image.asset("assets/images/placeholder.png", fit: BoxFit.fill),
                                          )),
                                  const SizedBox(width: 8),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                    stringArray.isNotEmpty ? text18(stringArray[0].toString()) : text18("License Not Detected"),
                                    textBold12(provd.feeds[index]['feed_name'].toString()),
                                    Text(DateFormat('dd MMM - hh:mm a').format(date).toString(), style: FFonts.labelStyle),
                                  ])
                                ])),
                          ),
                        ),
                      );
                    });
                  }),
            );
          }),
          Consumer<CommonProvider>(
            builder: (_, provd, __) {
              return provd.commonLoading ? loading50Button() : const SizedBox();
            },
          )
        ]),
      );
    });
  }
}
