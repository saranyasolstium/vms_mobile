import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../decoration/dialogs.dart';
import '../../../main.dart';
import '../../../provider/common_provider.dart';
import '../../../utilities/color.dart';
import '../../../utilities/fonts.dart';
import '../../../utilities/localvariable.dart';
import 'package:photo_view/photo_view.dart';

Widget content(String head, String data) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [textShade(head), textContent(data)]),
    );

class ImageFrame extends StatelessWidget {
  const ImageFrame({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 120,
        width: MediaQuery.of(context).size.width - 20,
        child: GestureDetector(
          onTap: () => commonDialog(context, bigImage(url), 400),
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) =>
                Image.asset("assets/images/placeholder.png"),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8), topLeft: Radius.circular(8)),
                shape: BoxShape.rectangle,
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
            errorWidget: (context, url, error) =>
                Image.asset("assets/images/placeholder.png"),
          ),
        ));
  }
}

Widget imageBox() => ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(width: 1.5, color: CColors.light)),
        child: Image.asset(
          "assets/images/car1.png",
          fit: BoxFit.cover,
        ),
      ),
    );

Widget unmatchedImage() => Consumer<CommonProvider>(builder: (_, provd, __) {
      return SizedBox(
          height: 150,
          width: (MediaQuery.of(indexKey.currentContext!).size.width),
          child: GestureDetector(
            onTap: () => commonDialog(
                indexKey.currentContext!,
                bigImage(
                    "${LocVar.imageUrl + provd.feeds[provd.feedIndex]['images']}.jpeg"),
                400),
            child: CachedNetworkImage(
              imageUrl:
                  "${LocVar.imageUrl + provd.feeds[provd.feedIndex]['images']}.jpeg",
              placeholder: (context, url) =>
                  Image.asset("assets/images/placeholder.png"),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  shape: BoxShape.rectangle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              errorWidget: (context, url, error) =>
                  Image.asset("assets/images/placeholder.png"),
            ),
          ));
    });

Widget vechicleImage() => Consumer<CommonProvider>(builder: (_, provd, __) {
      return provd.feeds[provd.feedIndex]['images'] != null
          ? SizedBox(
              height: 150,
              width: (MediaQuery.of(indexKey.currentContext!).size.width),
              child: GestureDetector(
                onTap: () => commonDialog(
                    indexKey.currentContext!,
                    bigImage(
                        "${LocVar.imageUrl + provd.feeds[provd.feedIndex]['images']}.jpeg"),
                    400),
                child: CachedNetworkImage(
                  imageUrl:
                      "${LocVar.imageUrl + provd.feeds[provd.feedIndex]['images']}.jpeg",
                  placeholder: (context, url) =>
                      Image.asset("assets/images/placeholder.png"),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/images/placeholder.png"),
                ),
              ))
          : SizedBox(
              height: 150,
              width: (MediaQuery.of(indexKey.currentContext!).size.width),
              child: Image.asset("assets/images/placeholder.png"));
    });

Widget bigImage(String image) => SizedBox(
      height: MediaQuery.of(indexKey.currentContext!).size.height,
      width: MediaQuery.of(indexKey.currentContext!).size.width,
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: 680,
                    maxWidth: 1280,
                    minHeight: 480,
                    maxHeight: 720),
                child: PhotoView(
                  imageProvider: NetworkImage(image),
                )

                // CachedNetworkImage(
                //   imageUrl: image,
                //   placeholder: (context, url) => Image.asset("assets/images/placeholder.png"),
                //   imageBuilder: (context, imageProvider) => Container(
                //     decoration: BoxDecoration(
                //       borderRadius: const BorderRadius.all(Radius.circular(8)),
                //       shape: BoxShape.rectangle,
                //       image: DecorationImage(image: imageProvider, fit: BoxFit.fitWidth),
                //     ),
                //   ),
                //   errorWidget: (context, url, error) => Image.asset("assets/images/placeholder.png"),
                // ),
                ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: CircleAvatar(
              backgroundColor: CColors.dark,
              radius: 16,
              child: Center(
                child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () =>
                        Navigator.of(indexKey.currentContext!).pop(),
                    icon: const Icon(Icons.clear,
                        size: 18, color: CColors.light)),
              ),
            ),
          )
        ],
      ),
    );
