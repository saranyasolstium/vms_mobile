import 'package:flutter/material.dart';

import '../decoration/text_fields.dart';

class TopBarWeb extends StatefulWidget {
  const TopBarWeb({Key? key}) : super(key: key);

  @override
  State<TopBarWeb> createState() => _TopBarWebState();
}

class _TopBarWebState extends State<TopBarWeb> {
  TextEditingController searchWeb = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 200,
      child: searchField("Search here", searchWeb),
    );
  }
}
