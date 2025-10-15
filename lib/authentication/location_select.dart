import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/provider/auth_provider.dart';
import 'package:vms_mobile_app/provider/common_provider.dart';
import 'package:vms_mobile_app/screens/mobile/main_screen.dart';
import 'package:vms_mobile_app/utilities/loaders.dart';
import '../decoration/dialogs.dart';
import '../utilities/color.dart';
import '../utilities/fonts.dart';
import '../widgets/sidebar.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  // @override
  //  void initState() {
  //   Future.delayed(const Duration(milliseconds: 500), () {
  //    Provider.of<CommonProvider>(context,listen: false).getLocations(context);
  //   });
  //    super.initState();
  //  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CColors.dark,
      body: Stack(
        children: [
          SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/images/loginbg.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: size.height,
            width: size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [topImage(), locationList()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? selected;

  Widget locationList() => Consumer<CommonProvider>(builder: (_, provd, __) {
        return provd.commonLoading
            ? loading50Button()
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: provd.locations.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      selected = index;
                      Provider.of<CommonProvider>(context, listen: false)
                          .setSelectedLocation(index, false);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MainScreen()),
                          (route) => false);
                    }),
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 12, left: 12, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: selected == index
                              ? CColors.appbar
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
      });

  Widget topImage() => SizedBox(
        height: 290,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              SizedBox(
                height: 125,
                width: 125,
                child: Image.asset("assets/images/logo.png"),
              ),
              textSideHeading("Select Location"),
              Consumer<AuthProvider>(builder: (_, provd, __) {
                return textBlue("Logged in as: ${provd.name}");
              }),
              TextButton(
                  onPressed: () =>
                      commonDialog(context, const LogoutDialog(), 300),
                  child: Text("Logout?", style: FFonts.formFont))
            ],
          ),
        ),
      );
}
