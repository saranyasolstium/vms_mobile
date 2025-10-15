import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms_mobile_app/decoration/container.dart';
import 'package:vms_mobile_app/provider/barcode_provider.dart';
import 'package:vms_mobile_app/screens/mobile/widgets/image_box.dart';

import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../decoration/buttons.dart';
import '../../decoration/text_fields.dart';
import '../../main.dart';
import '../../provider/common_provider.dart';
import '../../provider/unitprovider.dart';
import '../../service/api_service.dart';
import '../../utilities/color.dart';
import '../../utilities/fonts.dart';
import '../../utilities/loaders.dart';
import '../../utilities/notifications.dart';

var selectedPurpose;
int? totalPerson;
Map? purposeSelected;

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  List<String> selectedUnits = [];
  List<String> allUnits = [];
  String unitsString = "";

  // >>> FIX: local loading flags ONLY for Save buttons (prevents polling from toggling them)
  bool _savingVehicle = false; // vehicle tab Save
  bool _savingWalkIn = false; // walk-in tab Save

  void _initializeUnits() {
    // Generate units 200-434 (even numbers only)
    for (int i = 200; i <= 434; i += 2) {
      allUnits.add(i.toString());
    }
  }

  void _resetEntryForm() {
    setState(() {
      vehicleNo.clear();
      mobileControl.clear();
      nameControl.clear();
      icNumberCont.clear();
      emailControl.clear();
      contactPerson.clear();
      unitNumberCont.clear();
      companyNoControl.clear();
      passNoControl.clear();

      selectedPurpose = null;
      totalPerson = null;

      _image = null; // also clear captured photo if any
    });

    // also clear any suggestion lists etc.
    Provider.of<UnitProvider>(context, listen: false).clearUnitList();

    // hide keyboard
    FocusScope.of(context).unfocus();
  }
  // ================== Validation =================================

  bool _isEmpty(TextEditingController c) => c.text.trim().isEmpty;
  bool _isValidEmail(String s) => s.contains('@') && s.contains('.');

  // ========= Unified, flow-aware + purpose-driven validation =========

  String _purposeText() =>
      (selectedPurpose?['purpose'] ?? selectedPurpose?['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

  String _purposeRule() {
    final p = _purposeText();
    if (p.contains('delivery')) return 'delivery';
    if (p.contains('coach')) return 'coaching';
    if (p.contains('contract')) return 'contractor';
    if (p.contains('drop') || p.contains('pick')) return 'dropoff_pickup';
    return 'visitor';
  }

// Purpose-driven required fields
  Set<String> _requiredFieldsForPurpose(String rule) {
    switch (rule) {
      case 'delivery':
      case 'coaching':
        return {'mobile', 'unit'};
      case 'visitor': // all except IC
        return {
          'name',
          'email',
          'company',
          'contact',
          'unit',
          'persons',
          'pass'
        };
      case 'contractor': // all
        return {
          'name',
          'email',
          'company',
          'contact',
          'ic',
          'unit',
          'persons',
          'pass'
        };
      case 'dropoff_pickup':
        return {};
      default:
        return {};
    }
  }

// Base by flow
  Set<String> _baseRequiredForFlow({required bool isWalkIn}) {
    return isWalkIn ? {'mobile'} : {'vehicle'};
  }

  bool _isValidEmailLocal(String s) {
    final e = s.trim();
    if (e.isEmpty) return false;
    final reg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return reg.hasMatch(e);
  }

// For showing "*" in labels if you want dynamic indicators
  bool isReqUI(String key, {required bool isWalkIn}) {
    if (selectedPurpose == null) return false;
    final req = _requiredFieldsForPurpose(_purposeRule())
      ..addAll(_baseRequiredForFlow(isWalkIn: isWalkIn));
    return req.contains(key);
  }

// Main validator used by BOTH feed & walk-in
  String? validateFormUnified({required bool isWalkIn}) {
    final currentLocationId =
        Provider.of<CommonProvider>(context, listen: false).locations[
            Provider.of<CommonProvider>(context, listen: false)
                .selectedLocation]['location_id'];

    if (selectedPurpose == null) return "Kindly select the purpose";

    print("saranya $isWalkIn");

    // Merge base (by flow) + purpose-driven
    final requiredSet = <String>{}
      ..addAll(_baseRequiredForFlow(isWalkIn: isWalkIn))
      ..addAll(_requiredFieldsForPurpose(_purposeRule()));
    print(requiredSet);
    // vehicle
    if (requiredSet.contains('vehicle') && vehicleNo.text.trim().isEmpty) {
      return "Kindly enter vehicle number";
    }

    // mobile
    if (requiredSet.contains('mobile')) {
      if (mobileControl.text.trim().isEmpty) {
        return "Kindly enter mobile number";
      }
      if (mobileControl.text.trim().length < 8) {
        return "Kindly check your mobile number";
      }
    } else {
      // (optional) if provided, you can still sanity check
      if (mobileControl.text.isNotEmpty &&
          mobileControl.text.trim().length < 8) {
        return "Kindly check your mobile number";
      }
    }

    // name
    if (requiredSet.contains('name') && nameControl.text.trim().isEmpty) {
      return "Kindly enter visitor name";
    }

    // email
    if (requiredSet.contains('email')) {
      if (emailControl.text.trim().isEmpty) return "Kindly enter email address";
      if (!_isValidEmailLocal(emailControl.text)) {
        return "Kindly enter a valid email address";
      }
    } else {
      if (emailControl.text.isNotEmpty &&
          !_isValidEmailLocal(emailControl.text)) {
        return "Kindly enter a valid email address";
      }
    }

    // company
    if (requiredSet.contains('company') &&
        companyNoControl.text.trim().isEmpty) {
      return "Kindly enter company name";
    }

    // contact person
    if (requiredSet.contains('contact') && contactPerson.text.trim().isEmpty) {
      return "Kindly enter contact person name";
    }

    // IC
    if (requiredSet.contains('ic')) {
      if (icNumberCont.text.trim().isEmpty) return "Kindly enter IC number";
      if (icNumberCont.text.trim().length <= 4) {
        return "Kindly check your IC number";
      }
    } else {
      if (icNumberCont.text.isNotEmpty &&
          icNumberCont.text.trim().length <= 4) {
        return "Kindly check your IC number";
      }
    }

    // unit
    if (currentLocationId == "64f1d7a46fbcc7432ee4889c") {
      if (requiredSet.contains('unit') && unitsString.toString().isEmpty) {
        return "Kindly select unit number";
      }
    } else {
      if (requiredSet.contains('unit') && unitNumberCont.text.trim().isEmpty) {
        return "Kindly enter unit number";
      }
    }

    // persons
    if (requiredSet.contains('persons') && (totalPerson == null)) {
      return "Kindly select number of visitors";
    }

    // pass
    if (requiredSet.contains('pass') && passNoControl.text.trim().isEmpty) {
      return "Kindly enter V pass / C pass";
    }

    return null; // OK
  }

  // ===================================================

  // >>> FIX: make async so we can await and control _savingVehicle reliably
  Future<void> entryFunction() async {
    final err = validateFormUnified(isWalkIn: false); // vehicle required
    if (err != null) {
      notif('Failed', err);
      return;
    }

    Map<String, String> data = {};
    data.addAll({"vehicle_no": vehicleNo.text});
    data.addAll({"name": nameControl.text});
    data.addAll({"mobile_no": mobileControl.text});
    data.addAll({"email": emailControl.text});
    data.addAll({"contact_person": contactPerson.text});
    data.addAll({"ic_number": icNumberCont.text});
    data.addAll({"purpose_visit": selectedPurpose['purpose_id'].toString()});
    data.addAll({"company_no": companyNoControl.text});
    data.addAll({"pass_no": passNoControl.text});
    data.addAll(
        {"no_of_person": totalPerson == null ? "" : totalPerson.toString()});
    data.addAll({"in_time": DateTime.now().toString()});
    data.addAll({"unit_no": unitNumberCont.text});

    await Provider.of<CommonProvider>(context, listen: false).addEntry(data);
  }

  Timer? timer;

  callApi() {
    List feeds =
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
            .feeds;
    if (feeds.isEmpty) {
      return Provider.of<CommonProvider>(indexKey.currentContext!,
              listen: false)
          .getEntryFeed();
    } else {
      return;
    }
  }

  final unitkey = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
            .getPurpose());
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) => callApi());
    _initializeUnits();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool type = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              // const SizedBox(height: 50),
              // searchAllScreen(context),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    type ? textSideHeading("Entry") : textSideHeading("Entry"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            splashRadius: 18,
                            onPressed: () => setState(() {
                                  type = true;
                                  _resetEntryForm();

                                  Provider.of<CommonProvider>(
                                          indexKey.currentContext!,
                                          listen: false)
                                      .getEntryFeed();
                                }),
                            icon: Icon(
                                type
                                    ? Icons.radio_button_on
                                    : Icons.radio_button_off,
                                color: CColors.brand1,
                                size: 22)),
                        textBlue("Vehicle"),
                        const SizedBox(width: 12),
                        IconButton(
                            splashRadius: 18,
                            onPressed: () => setState(() {
                                  type = false;
                                  _resetEntryForm();
                                  vehicleNo.clear();
                                }),
                            icon: Icon(
                                type
                                    ? Icons.radio_button_off
                                    : Icons.radio_button_on,
                                color: CColors.brand1,
                                size: 22)),
                        textBlue("Walk In"),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
              Consumer<CommonProvider>(builder: (_, provd, __) {
                return type == false ? walkInEntry() : feedEntry(provd.feeds);
              })
            ]),
          ),
        ),
      ],
    );
  }

  Widget feedEntry(List list) {
    return list.isEmpty
        ? SizedBox(
            height: 400,
            child: Center(child: Consumer<CommonProvider>(
              builder: (_, provider, __) {
                return provider.commonLoading
                    ? loading50Button()
                    : GestureDetector(
                        onTap: () => Provider.of<CommonProvider>(
                                indexKey.currentContext!,
                                listen: false)
                            .getEntryFeed(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh,
                                color: CColors.brand1, size: 32),
                            textSideHeading("Refresh"),
                            const SizedBox(height: 6),
                            textDesc("No entry feed, click to refresh!")
                          ],
                        ),
                      );
              },
            )),
          )
        : Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: vechicleImage()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(children: [
                  const SizedBox(height: 16),
                  //
                  Consumer<CommonProvider>(builder: (_, provd, __) {
                    DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss")
                        .parse(provd.feeds[provd.feedIndex]['date_time']);
                    return provd.blockedVehicle == 1
                        ? textRed("!Black Listed Vehicle!")
                        : text18(
                            "Feed Entry Time: ${DateFormat('dd MMM hh:mm a').format(date)}");
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 + 64,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              inputFormatters: [UpperCaseTextFormatter()],
                              cursorColor: CColors.shade1,
                              cursorHeight: 24,
                              // onTap: () => setState(() {
                              //   enteringData = true;
                              // }),
                              onChanged: (val) => Provider.of<CommonProvider>(
                                      context,
                                      listen: false)
                                  .getVehicleData(val),
                              controller: vehicleNo,
                              style: FFonts.formFont,
                              decoration: InputDecoration(
                                label: const Text("Vehicle*"),
                                labelStyle: FFonts.labelStyle,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding: const EdgeInsets.only(left: 18),
                                enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1)),
                                focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<CommonProvider>(builder: (_, provd, __) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: provd.commonLoading
                              ? loading50Button()
                              : buttonWidth("Skip", () {
                                  mobileControl.clear();
                                  nameControl.clear();
                                  icNumberCont.clear();
                                  contactPerson.clear();
                                  emailControl.clear();
                                  unitNumberCont.clear();
                                  selectedPurpose = null;
                                  totalPerson = null;

                                  // setState(() {
                                  //   enteringData = false;
                                  // });
                                  Provider.of<CommonProvider>(context,
                                          listen: false)
                                      .incrementFeedIndex();
                                }, MediaQuery.of(context).size.width / 2 - 100),
                        );
                      })
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 28,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          inputFormatters: [UpperCaseTextFormatter()],
                          cursorColor: CColors.shade1,
                          cursorHeight: 24,
                          maxLength: 13,
                          keyboardType: TextInputType.phone,
                          onChanged: (val) {
                            if (val.length >= 8) {
                              Provider.of<CommonProvider>(context,
                                      listen: false)
                                  .getMobileNumberData(val);
                            }
                          },
                          // onTap: () => setState(() {
                          //   enteringData = true;
                          // }),
                          controller: mobileControl,
                          style: FFonts.formFont,
                          decoration: InputDecoration(
                            label: const Text("Mobile*"),
                            labelStyle: FFonts.labelStyle,
                            counterText: "",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.only(left: 18),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    width: 1, color: CColors.shade1)),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(
                                    width: 1, color: CColors.shade1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 100, child: textBlue("Purpose")),
                      const SizedBox(width: 12),
                      Consumer<CommonProvider>(builder: (_, provd, __) {
                        return Container(
                          key: unitkey,
                          height: 50,
                          padding: const EdgeInsets.only(left: 12),
                          width: MediaQuery.of(context).size.width - 136,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: CColors.shade1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            dropdownColor: CColors.dark,
                            style: FFonts.formFont,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                filled: false,
                                hintStyle: FFonts.formFont,
                                hintText: "Purpose of Visit"),
                            value: selectedPurpose != null
                                ? selectedPurpose['purpose_id']
                                : null,
                            items: provd.purpose.map((item) {
                              return DropdownMenuItem(
                                value: item['purpose_id'],
                                child: textProfile(item['purpose']),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                selectedPurpose = provd.purpose.firstWhere(
                                    (element) =>
                                        element['purpose_id'] == newVal,
                                    orElse: () => null);
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        cursorColor: CColors.shade1,
                        cursorHeight: 24,
                        maxLength: 12,
                        // onTap: () => setState(() {
                        //   enteringData = true;
                        // }),
                        onChanged: (val) =>
                            Provider.of<UnitProvider>(context, listen: false)
                                .getUnitList(val),
                        controller: unitNumberCont,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.streetAddress,
                        style: FFonts.formFont,
                        onTap: () =>
                            Scrollable.ensureVisible(unitkey.currentContext!),
                        decoration: InputDecoration(
                          label: const Text("Unit Number"),
                          counterText: "",
                          labelStyle: FFonts.labelStyle,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.only(left: 18),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide:
                                  BorderSide(width: 1, color: CColors.shade1)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide:
                                  BorderSide(width: 1, color: CColors.shade1)),
                        ),
                      ),
                    ),
                  ),
                  Consumer<UnitProvider>(builder: (_, provider, __) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: provider.unitList.length * 78 + 8,
                      child: ListView.builder(
                          itemCount: provider.unitList.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  unitNumberCont.text =
                                      provider.unitList[index]['unit_name'];
                                  nameControl.text =
                                      provider.unitList[index]['name'];
                                  mobileControl.text =
                                      provider.unitList[index]['contact_no'];
                                  icNumberCont.text =
                                      provider.unitList[index]['ic_number'];
                                });
                                Provider.of<UnitProvider>(context,
                                        listen: false)
                                    .clearUnitList();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: decorCard3(),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    textSideHeading(
                                        provider.unitList[index]['unit_name']),
                                    const SizedBox(height: 8),
                                    textSideBar(
                                        provider.unitList[index]['name']),
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }),
                  authField("Name", nameControl, 50, TextInputType.text,
                      TextCapitalization.words),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: authField("IC Number", icNumberCont, 9,
                            TextInputType.text, TextCapitalization.characters)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Provider.of<BarcodeProvider>(context, listen: false)
                            .scanBarcode()
                            .then((value) {
                          if (!mounted || value.isEmpty) return;

                          setState(() {
                            icNumberCont.text = value; // show full IC
                          });
                          FocusScope.of(context).unfocus();
                        });

                        // Provider.of<BarcodeProvider>(context, listen: false)
                        //     .scanBarcode()
                        //     .then((value) => setState(() {
                        //           icNumberCont.text = value;
                        //           icNumberCont.text = icNumberCont.text
                        //               .replaceRange(1, 5, '****');
                        //           FocusScope.of(context).unfocus();
                        //         }));
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: CColors.brand1,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Image(
                          image: AssetImage('assets/images/barcode.png'),
                          color: Colors.white,
                        ),
                      ),
                    )
                  ]),
                  authField("Company Name", companyNoControl, 50,
                      TextInputType.visiblePassword, TextCapitalization.none),
                  authField("V pass / C pass", passNoControl, 50,
                      TextInputType.visiblePassword, TextCapitalization.none),
                  authField("E-Mail", emailControl, 50,
                      TextInputType.emailAddress, TextCapitalization.none),
                  authField("Contact Person", contactPerson, 50,
                      TextInputType.text, TextCapitalization.words),
                  Row(
                    children: [
                      SizedBox(width: 100, child: textBlue("Person's")),
                      const SizedBox(width: 12),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.only(left: 16),
                        width: MediaQuery.of(context).size.width - 136,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: CColors.shade1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: DropdownButton<int>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: CColors.dark,
                            style: FFonts.formFont,
                            hint: Text("Number of Visitor's",
                                style: FFonts.formFont),
                            value: totalPerson,
                            items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                                .map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                totalPerson = newVal;
                              });
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // >>> FIX: use local _savingVehicle instead of provider.commonLoading2 for Save button
                  _savingVehicle
                      ? loading50Button()
                      : Row(
                          children: [
                            SizedBox(
                                child: buttonWidth("Save", () async {
                              // keep your validation inside entryFunction
                              setState(() => _savingVehicle = true);
                              try {
                                await entryFunction();
                              } finally {
                                if (mounted) {
                                  setState(() => _savingVehicle = false);
                                }
                              }
                            }, MediaQuery.of(context).size.width / 3 * 2 - 16)),
                            const SizedBox(width: 8),
                            SizedBox(
                                child: buttonWidth("Clear", () {
                              print('Vehicle Entry');
                              setState(() {
                                mobileControl.clear();
                                nameControl.clear();
                                icNumberCont.clear();
                                emailControl.clear();
                                contactPerson.clear();
                                unitNumberCont.clear();
                                selectedPurpose = null;
                                totalPerson = null;
                                companyNoControl.clear(); // Company Name
                                passNoControl.clear(); // V pass / C pass
                                selectedUnits = [];
                                unitsString = "";
                              });
                            }, MediaQuery.of(context).size.width / 3 - 16)),
                          ],
                        ),
                ]),
              ),
              const SizedBox(height: 180),
            ],
          );
  }

  final picker = ImagePicker();
  late String base64Image;
  File? _image;

  Future getCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {}
    });
  }

  Widget walkInEntry() {
    final currentLocationId =
        Provider.of<CommonProvider>(context, listen: false).locations[
            Provider.of<CommonProvider>(context, listen: false)
                .selectedLocation]['location_id'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: [
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => getCamera(),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      height: 124,
                      width: 100,
                      decoration: const BoxDecoration(
                          color: CColors.appbar,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: _image != null
                          ? Align(
                              alignment: Alignment.center,
                              child: Image.file(_image!, fit: BoxFit.fitWidth))
                          : const Icon(Icons.camera_alt,
                              color: CColors.dark, size: 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                    width: MediaQuery.of(context).size.width - 136,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 + 64,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SizedBox(
                              height: 50,
                              child: TextFormField(
                                inputFormatters: [UpperCaseTextFormatter()],
                                cursorColor: CColors.shade1,
                                cursorHeight: 24,
                                onChanged: (val) => Provider.of<CommonProvider>(
                                        context,
                                        listen: false)
                                    .getVehicleData(val),
                                controller: vehicleNo,
                                style: FFonts.formFont,
                                decoration: InputDecoration(
                                  label: const Text("Vehicle"),
                                  labelStyle: FFonts.labelStyle,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding:
                                      const EdgeInsets.only(left: 18),
                                  enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          width: 1, color: CColors.shade1)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          width: 1, color: CColors.shade1)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 + 64,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SizedBox(
                              height: 50,
                              child: TextFormField(
                                inputFormatters: [UpperCaseTextFormatter()],
                                cursorColor: CColors.shade1,
                                cursorHeight: 24,
                                maxLength: 13,
                                keyboardType: TextInputType.phone,
                                onChanged: (val) {
                                  if (val.length >= 8) {
                                    Provider.of<CommonProvider>(context,
                                            listen: false)
                                        .getMobileNumberData(val);
                                  }
                                },
                                controller: mobileControl,
                                style: FFonts.formFont,
                                decoration: InputDecoration(
                                  label: const Text("Mobile*"),
                                  labelStyle: FFonts.labelStyle,
                                  counterText: "",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding:
                                      const EdgeInsets.only(left: 18),
                                  enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          width: 1, color: CColors.shade1)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          width: 1, color: CColors.shade1)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
            Row(
              children: [
                SizedBox(width: 100, child: textDesc("Purpose")),
                const SizedBox(width: 12),
                Consumer<CommonProvider>(builder: (_, provd, __) {
                  return Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 12),
                    width: MediaQuery.of(context).size.width - 136,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: CColors.shade1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12))),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      dropdownColor: CColors.dark,
                      style: FFonts.formFont,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          filled: false,
                          hintStyle: FFonts.formFont,
                          hintText: "Purpose of Visit"),
                      value: selectedPurpose != null
                          ? selectedPurpose['purpose_id']
                          : null,
                      items: provd.purpose.map((item) {
                        return DropdownMenuItem(
                          value: item['purpose_id'],
                          child: textProfile(item['purpose']),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          selectedPurpose = provd.purpose.firstWhere(
                              (element) => element['purpose_id'] == newVal,
                              orElse: () => null);
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            authField("Name", nameControl, 50, TextInputType.text,
                TextCapitalization.words),

            (currentLocationId == "64f1d7a46fbcc7432ee4889c")
                ?
                // Multi-select dropdown for location 9788512142
                Column(
                    children: [
                      MultiSelectDialogField<String>(
                        initialValue: selectedUnits,
                        listType: MultiSelectListType.LIST,
                        dialogHeight: 500,
                        dialogWidth: 400,
                        backgroundColor: Colors.white,
                        checkColor: Colors.white,
                        selectedColor: Colors.blueAccent,
                        itemsTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        selectedItemsTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: BoxDecoration(
                          color: CColors.shade2.withOpacity(0.1),
                          border: Border.all(width: 1, color: CColors.shade2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        items: allUnits
                            .map((unit) => MultiSelectItem(unit, unit))
                            .toList(),
                        title: Text(
                          "Select Units",
                          style: FFonts.labelStyle,
                        ),
                        buttonIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: CColors.light,
                        ),
                        buttonText: Text(
                          selectedUnits.isEmpty
                              ? "Select Units"
                              : '${selectedUnits.length} Selected',
                          style: FFonts.labelStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onConfirm: (results) {
                          setState(() {
                            selectedUnits = results.cast<String>();
                            unitsString = selectedUnits.join(
                                ", "); // This creates: "200, 202, 204, 206, 208"
                            print("Selected units: $unitsString");
                          });
                        },
                        chipDisplay: MultiSelectChipDisplay(
                          items: selectedUnits
                              .map((unit) => MultiSelectItem(unit, unit))
                              .toList(),
                          chipColor: CColors.shade1,
                          textStyle:
                              FFonts.labelStyle.copyWith(color: CColors.light),
                          onTap: (value) {
                            setState(() {
                              selectedUnits.remove(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        key: unitkey,
                        cursorColor: CColors.shade1,
                        cursorHeight: 24,
                        maxLength: 12,
                        onChanged: (val) =>
                            Provider.of<UnitProvider>(context, listen: false)
                                .getUnitList(val),
                        controller: unitNumberCont,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.streetAddress,
                        style: FFonts.formFont,
                        decoration: InputDecoration(
                          label: const Text("Unit Number"),
                          counterText: "",
                          labelStyle: FFonts.labelStyle,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.only(left: 18),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide:
                                  BorderSide(width: 1, color: CColors.shade1)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide:
                                  BorderSide(width: 1, color: CColors.shade1)),
                        ),
                      ),
                    ),
                  ),
            Consumer<UnitProvider>(builder: (_, provider, __) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: provider.unitList.length * 78 + 8,
                child: ListView.builder(
                    itemCount: provider.unitList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            unitNumberCont.text =
                                provider.unitList[index]['unit_name'] ?? "";
                            nameControl.text =
                                provider.unitList[index]['name'] ?? "";
                            mobileControl.text =
                                provider.unitList[index]['contact_no'] ?? "";
                            icNumberCont.text =
                                provider.unitList[index]['ic_number'] ?? "";
                          });
                          Provider.of<UnitProvider>(context, listen: false)
                              .clearUnitList();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: decorCard3(),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textSideHeading(
                                  provider.unitList[index]['unit_name']),
                              const SizedBox(height: 8),
                              textSideBar(provider.unitList[index]['name']),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: authField("IC Number", icNumberCont, 9,
                      TextInputType.text, TextCapitalization.characters)),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  Provider.of<BarcodeProvider>(context, listen: false)
                      .scanBarcode()
                      .then((value) {
                    if (!mounted || value.isEmpty) return;

                    setState(() {
                      icNumberCont.text = value; // show full IC
                    });
                    FocusScope.of(context).unfocus();
                  });
                },
                child: Container(
                  height: 48,
                  width: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: CColors.brand1,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Image(
                    image: AssetImage('assets/images/barcode.png'),
                    color: Colors.white,
                  ),
                ),
              )
            ]),
            authField("Company Name", companyNoControl, 50,
                TextInputType.visiblePassword, TextCapitalization.none),
            authField("V pass / C pass", passNoControl, 50,
                TextInputType.visiblePassword, TextCapitalization.none),
            authField("E-mail", emailControl, 50, TextInputType.emailAddress,
                TextCapitalization.none),
            authField("Contact Person", contactPerson, 50, TextInputType.text,
                TextCapitalization.words),
            Row(
              children: [
                SizedBox(width: 100, child: textDesc("Person's")),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 16),
                  width: MediaQuery.of(context).size.width - 136,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: CColors.shade1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: DropdownButton<int>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: CColors.dark,
                      style: FFonts.formFont,
                      hint: Text("Number of Visitor's", style: FFonts.formFont),
                      value: totalPerson,
                      items:
                          <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          totalPerson = newVal;
                        });
                      }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // >>> FIX: use local _savingWalkIn instead of provider.commonLoading for Save button
            _savingWalkIn
                ? loading50Button()
                : Row(
                    children: [
                      SizedBox(
                          child: buttonWidth("Save", () async {
                        setState(() => _savingWalkIn = true);
                        try {
                          await walkIn(currentLocationId);
                        } finally {
                          if (mounted) setState(() => _savingWalkIn = false);
                        }
                      }, MediaQuery.of(context).size.width / 3 * 2 - 16)),
                      const SizedBox(width: 8),
                      SizedBox(
                          child: buttonWidth("Clear", () {
                        print('walkin');
                        setState(() {
                          vehicleNo.clear();
                          mobileControl.clear();
                          nameControl.clear();
                          icNumberCont.clear();
                          emailControl.clear();
                          contactPerson.clear();
                          unitNumberCont.clear();
                          selectedPurpose = null;
                          totalPerson = null;
                          companyNoControl.clear();
                          passNoControl.clear();
                        });
                      }, MediaQuery.of(context).size.width / 3 - 16)),
                    ],
                  ),
          ]),
        ),
        const SizedBox(height: 180),
      ],
    );
  }

  Future<void> walkIn(String currentLocationId) async {
    // *** VALIDATION HOOK (Walk-in mode) ***
    if (currentLocationId == "64f1d7a46fbcc7432ee4889c") {
      if (mobileControl.text.trim().isEmpty) {
        notif('Failed', "Kindly enter mobile number");
        return; // << stop here
      } else if (mobileControl.text.trim().length < 8) {
        notif('Failed', "Kindly check your mobile number");
        return;
      } else if (selectedPurpose == null) {
        notif('Failed', "Kindly select the purpose");
        return;
      } else if (nameControl.text.trim().isEmpty) {
        notif('Failed', "Kindly enter visitor name");
        return;
      } else if (totalPerson == null) {
        notif('Failed', "Kindly select number of visitors");
        return;
      } else if (unitsString.isEmpty) {
        // ensure unit(s) selected for this site
        notif('Failed', "Kindly select unit number");
        return;
      }
    } else {
      final err = validateFormUnified(isWalkIn: true); // mobile required
      if (err != null) {
        notif('Failed', err);
        return;
      }
    }

    var data = {
      "vehicle_no": vehicleNo.text,
      "mobile_no": mobileControl.text,
      "name": nameControl.text,
      "ic_number": icNumberCont.text,
      "contact_person": contactPerson.text,
      "purpose_visit": selectedPurpose['purpose_id'].toString(),
      "in_time": DateTime.now().toString(),
      "email": emailControl.text,
      "no_of_person": totalPerson.toString(),
      'company_no': companyNoControl.text,
      'pass_no': passNoControl.text,
      "location_id": Provider.of<CommonProvider>(indexKey.currentContext!,
                  listen: false)
              .locations[
          Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
              .selectedLocation]['location_id'],
      "unit_no": currentLocationId == "64f1d7a46fbcc7432ee4889c"
          ? unitsString
          : unitNumberCont.text,
      "image_capture": _image != null
          ? base64Image = base64Encode(_image!.readAsBytesSync())
          : "",
    };
    print('Payload $data');
    print("saranya");
    return storeWalkInEntry(data);
  }

  // >>> FIX: make async so callers can await (used by walkIn)
  Future<void> storeWalkInEntry(var data) async {
    Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .loadingOn();
    final value = await ApiService()
        .post(indexKey.currentContext!, "walkIn_entry", params: data);
    Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .loadingOff();
    print(value);
    if (value['status'] == "success") {
      vehicleNo.clear();
      mobileControl.clear();
      nameControl.clear();
      icNumberCont.clear();
      contactPerson.clear();
      emailControl.clear();
      unitNumberCont.clear();
      companyNoControl.clear();
      passNoControl.clear();
      totalPerson = null;
      selectedPurpose = null;
      selectedUnits.clear();
      unitsString = "";

      return notif('Success', value["message"]);
    } else {
      return notif('Failed', value["message"]);
    }
  }
}

TextEditingController nameControl = TextEditingController();
TextEditingController vehicleNo = TextEditingController();
TextEditingController mobileControl = TextEditingController();
TextEditingController companyNoControl = TextEditingController();
TextEditingController passNoControl = TextEditingController();
TextEditingController emailControl = TextEditingController();
TextEditingController contactPerson = TextEditingController();
TextEditingController icNumberCont = TextEditingController();
TextEditingController unitNumberCont = TextEditingController();

@override
void dispose() {
  nameControl.dispose();
  vehicleNo.dispose();
  mobileControl.dispose();
  companyNoControl.dispose();
  passNoControl.dispose();
  emailControl.dispose();
  contactPerson.dispose();
  icNumberCont.dispose();
  unitNumberCont.dispose();
}
