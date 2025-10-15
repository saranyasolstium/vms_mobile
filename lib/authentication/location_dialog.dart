import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../decoration/container.dart';
import '../main.dart';
import '../provider/common_provider.dart';
import '../utilities/color.dart';
import '../utilities/fonts.dart';

class LocationDialog extends StatefulWidget {
  const LocationDialog({Key? key}) : super(key: key);

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  int selected = 0;

  check() {
    return Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .storeSetting();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        selected =
            Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
                .selectedLocation;
      });
      Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
          .getCameras();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selectLocation(),
              const SizedBox(width: 12),
              selectEntryCamera(),
              const SizedBox(width: 12),
              selectExitCamera(),
              const SizedBox(width: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: CColors.dark,
              child: IconButton(
                  onPressed: () => check(),
                  icon:
                      const Icon(Icons.check, color: CColors.light, size: 24)),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: CColors.dark,
              child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon:
                      const Icon(Icons.clear, color: CColors.light, size: 24)),
            ),
          ],
        ),
      ],
    );
  }

  Widget selectEntryCamera() {
    return Container(
      decoration: decorDark(),
      height: MediaQuery.of(context).size.height / 2 + 100,
      width: MediaQuery.of(context).size.width - 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: textSideHeading("Select Entry Camera"),
          ),
          const SizedBox(height: 12),
          Consumer<CommonProvider>(builder: (_, provd, __) {
            return provd.cameraList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: textButton("No camera in selected location"),
                  )
                : Expanded(
                    child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: provd.cameraList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() {
                              Provider.of<CommonProvider>(
                                      indexKey.currentContext!,
                                      listen: false)
                                  .setEntryCameraInt(index);
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 12, left: 12, bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: provd.entryCameraInt == index
                                      ? CColors.shade2.withOpacity(0.40)
                                      : CColors.appbar,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textSideHeading(
                                      provd.cameraList[index]["feed_name"]),
                                  const SizedBox(height: 6),
                                  textDesc(provd.cameraList[index]["feed_id"]),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
          }),
        ],
      ),
    );
  }

  Widget selectExitCamera() {
    return Container(
      decoration: decorDark(),
      height: MediaQuery.of(context).size.height / 2 + 100,
      width: MediaQuery.of(context).size.width - 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: textSideHeading("Select Exit Camera"),
          ),
          const SizedBox(height: 12),
          Consumer<CommonProvider>(builder: (_, provd, __) {
            return provd.cameraList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: textButton("No camera in selected location"),
                  )
                : Expanded(
                    child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: provd.cameraList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() {
                              Provider.of<CommonProvider>(
                                      indexKey.currentContext!,
                                      listen: false)
                                  .setExitCameraInt(index);
                              // selectedExit = index;
                              // exitCameraInt = index;
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 12, left: 12, bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: provd.exitCameraInt == index
                                      ? CColors.shade2.withOpacity(0.40)
                                      : CColors.appbar,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textSideHeading(
                                      provd.cameraList[index]["feed_name"]),
                                  const SizedBox(height: 6),
                                  textDesc(provd.cameraList[index]["feed_id"]),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
          }),
        ],
      ),
    );
  }

  Widget selectLocation() {
    return Container(
      decoration: decorDark(),
      height: MediaQuery.of(context).size.height / 2 + 100,
      width: MediaQuery.of(context).size.width - 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: textSideHeading("Select Location"),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<CommonProvider>(builder: (_, provd, __) {
              return ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: provd.locations.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        selected = index;
                        Provider.of<CommonProvider>(context, listen: false)
                            .setSelectedLocation(index, true);
                        // selectedExit = 0;
                        // selectedEntry = 0;
                        // if (selected == selectedGateway) {
                        //   selectedExit = exitCameraInt;
                        //   selectedEntry = entryCameraInt;
                        // }
                        // Navigator.of(context).pop();
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 12, left: 12, bottom: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: selected == index
                                ? CColors.shade2.withOpacity(0.40)
                                : CColors.appbar,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textSideHeading(
                                provd.locations[index]["location_name"]),
                            const SizedBox(height: 8),
                            textDesc(provd.locations[index]["location_id"]),
                          ],
                        ),
                      ),
                    );
                  });
            }),
          ),
        ],
      ),
    );
  }
}

// int entryCameraInt = 0;
// int exitCameraInt = 0;
// int selectedGateway = 0;
