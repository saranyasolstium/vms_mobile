import 'package:flutter/cupertino.dart';

import '../utilities/color.dart';

BoxDecoration decorCard2() => BoxDecoration( border: Border.all(width: 2, color: CColors.brand1),
    color: CColors.dark, borderRadius: const BorderRadius.all(Radius.circular(8)));

BoxDecoration decorFilled() => BoxDecoration(
    color: CColors.shade2,
    border: Border.all(width: 1, color: CColors.brand1),
    borderRadius: const BorderRadius.all(Radius.circular(12)));

Container contShade1(BuildContext context, Widget child) => Container(
    height: 150,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(top: 16, right: 12, left: 12),
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
        color: CColors.shade1,
        borderRadius: BorderRadius.all(Radius.circular(12))),
    child: child);

Container contShade2(BuildContext context, double heig, Widget child) =>
    Container(
        height: heig,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
            color: CColors.shade2,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: child);

BoxDecoration decorCard() => const BoxDecoration(
    color: CColors.dark, borderRadius: BorderRadius.all(Radius.circular(12)));

BoxDecoration decorImage() => BoxDecoration(
    color: CColors.shade2,
    border: Border.all(width: 2, color: CColors.light.withOpacity(0.75)),
    borderRadius: const BorderRadius.all(Radius.circular(12)));

BoxDecoration decorCard3() => const BoxDecoration(
    color: CColors.appbar, borderRadius: BorderRadius.all(Radius.circular(8)));

BoxDecoration decorUnSelected() => const BoxDecoration(
    color: CColors.dark, borderRadius: BorderRadius.all(Radius.circular(12)));

BoxDecoration decorSelected() => BoxDecoration(
    color: CColors.dark,
    border: Border.all(width: 1, color: CColors.brand1),
    borderRadius: const BorderRadius.all(Radius.circular(12)));

BoxDecoration decorDark() => const BoxDecoration(
    color: CColors.dark, borderRadius: BorderRadius.all(Radius.circular(12)));
