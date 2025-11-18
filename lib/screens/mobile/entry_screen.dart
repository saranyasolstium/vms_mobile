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

// ======================================================
// Globals (keep as you already had)
var selectedPurpose;
int? totalPerson;
Map? purposeSelected;
// ======================================================

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  // Units multi-select for special site
  List<String> selectedUnits = [];
  List<String> allUnits = [];
  String unitsString = "";

  // Loading flags (Save buttons only)
  bool _savingVehicle = false; // vehicle tab Save
  bool _savingWalkIn = false; // walk-in tab Save

  // Controllers
  final TextEditingController _unitTextController = TextEditingController();

  // NEW: controller for "Other" purpose text
  final TextEditingController _otherPurposeCtrl = TextEditingController();

  // Picker / image
  final picker = ImagePicker();
  late String base64Image;
  File? _image;

  // Polling
  Timer? timer;

  // Mode toggle: true => Vehicle(feed), false => Walk-in
  bool type = true;

  // ---------- INIT / DISPOSE ----------
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
          .getPurpose();
    });
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) => callApi());
    _initializeUnits();
  }

  @override
  void dispose() {
    timer?.cancel();
    _unitTextController.dispose();
    _otherPurposeCtrl.dispose(); // NEW
    super.dispose();
  }

  // ---------- HELPERS ----------
  void _initializeUnits() {
    // Generate units 200-434 (even numbers only)
    for (int i = 200; i <= 434; i += 2) {
      allUnits.add(i.toString());
    }
  }

  String _purposeText() =>
      (selectedPurpose?['purpose'] ?? selectedPurpose?['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

  // Detect exact "Other"
  bool _isOtherPurpose() {
    return _purposeText() == 'other';
  }

  // Purpose rule mapping
  String _purposeRule() {
    final p = _purposeText();
    if (p.contains('delivery')) return 'delivery';
    if (p.contains('coach')) return 'coaching';
    if (p.contains('contract')) return 'contractor';
    if (p.contains('drop') || p.contains('pick')) return 'dropoff_pickup';
    if (p == 'other') return 'other';
    return 'visitor';
  }

  // Helper: Contract checks for special site label handling
  bool _isContractPurpose() {
    final p = _purposeText();
    return p.contains('contract') && !p.contains('out of contract');
  }

  bool _isOutOfContractPurpose() {
    final p = _purposeText();
    return p.contains('out of contract');
  }

  // Contact person visibility rule (respects site override)
  bool _shouldShowContactPersonField({required bool isWalkIn}) {
    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];

    if (currentLocationId == "64f1d7a46fbcc7432ee4889c") {
      return _isContractPurpose() && !_isOutOfContractPurpose();
    }
    final requiredSet = _requiredFieldsForPurpose(_purposeRule())
      ..addAll(_baseRequiredForFlow(isWalkIn: isWalkIn));
    return requiredSet.contains('contact');
  }

  // Contact person dynamic label (site override)
  String _getContactPersonLabel() {
    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];
    if (currentLocationId == "64f1d7a46fbcc7432ee4889c" &&
        _isContractPurpose()) {
      return "Purpose of Contractor";
    }
    return "Contact Person";
  }

  // Purpose-driven required fields
  Set<String> _requiredFieldsForPurpose(String rule) {
    switch (rule) {
      case 'delivery':
      case 'coaching':
        return {'mobile', 'unit'};
      case 'visitor':
        return {
          'name',
          'unit',
          'company',
          'pass',
          'email',
          'contact',
          'persons',
        };
      case 'contractor':
        return {
          'name',
          'unit',
          'company',
          'pass',
          'email',
          'contact',
          'ic',
          'persons',
        };
      case 'dropoff_pickup':
        return {};
      case 'other': // Only base-by-flow + other text (handled in validator)
        return {};
      default:
        return {};
    }
  }

  // Base-by-flow requirements
  Set<String> _baseRequiredForFlow({required bool isWalkIn}) {
    return isWalkIn ? {'mobile'} : {'vehicle'};
  }

  bool _isValidEmailLocal(String s) {
    final e = s.trim();
    if (e.isEmpty) return false;
    final reg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return reg.hasMatch(e);
  }

  // UI indicator helper
  bool isReqUI(String key, {required bool isWalkIn}) {
    if (selectedPurpose == null) return false;
    final req = _requiredFieldsForPurpose(_purposeRule())
      ..addAll(_baseRequiredForFlow(isWalkIn: isWalkIn));
    return req.contains(key);
  }

  // Unified validator (used by both modes)
  String? validateFormUnified({required bool isWalkIn}) {
    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];

    if (selectedPurpose == null) return "Kindly select the purpose";

    // OTHER: only base + other text required (others optional)
    if (_isOtherPurpose()) {
      final baseReq = _baseRequiredForFlow(isWalkIn: isWalkIn);
      if (baseReq.contains('vehicle') && vehicleNo.text.trim().isEmpty) {
        return "Kindly enter vehicle number";
      }
      if (baseReq.contains('mobile')) {
        if (mobileControl.text.trim().isEmpty) {
          return "Kindly enter mobile number";
        }
        if (mobileControl.text.trim().length < 8) {
          return "Kindly check your mobile number";
        }
      }
      if (_otherPurposeCtrl.text.trim().isEmpty) {
        return "Kindly specify the other purpose";
      }
      return null; // valid
    }

    // Non-OTHER original path
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
      if (mobileControl.text.isNotEmpty &&
          mobileControl.text.trim().length < 8) {
        return "Kindly check your mobile number";
      }
    }

    // unit (note: you had a != typo previously; keeping your original guard)
    if (currentLocationId != "64f1d7a46fbcc2ee4889c") {
      if (requiredSet.contains('unit') && unitNumberCont.text.trim().isEmpty) {
        return "Kindly enter unit number";
      }
    }

    // name
    if (requiredSet.contains('name') && nameControl.text.trim().isEmpty) {
      return "Kindly enter visitor name";
    }

    // company
    if (requiredSet.contains('company') &&
        companyNoControl.text.trim().isEmpty) {
      return "Kindly enter company name";
    }

    // pass
    if (requiredSet.contains('pass') && passNoControl.text.trim().isEmpty) {
      return "Kindly enter V pass / C pass";
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

    // contact (respect visibility + site override)
    final shouldShowContact = _shouldShowContactPersonField(isWalkIn: isWalkIn);
    if (shouldShowContact) {
      if (currentLocationId == "64f1d7a46fbcc7432ee4889c") {
        if (_isContractPurpose() && contactPerson.text.trim().isEmpty) {
          return "Kindly enter Purpose of Contractor";
        } else if (requiredSet.contains('contact') &&
            contactPerson.text.trim().isEmpty) {
          return "Kindly enter contact person name";
        }
      } else {
        if (requiredSet.contains('contact') &&
            contactPerson.text.trim().isEmpty) {
          return "Kindly enter contact person name";
        }
      }
    }

    // IC
    if (currentLocationId != "26f697c540f2015daf77f4a") {
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
    }

    // persons
    if (requiredSet.contains('persons') && (totalPerson == null)) {
      return "Kindly select number of visitors";
    }

    return null; // OK
  }

  // Poll feed
  callApi() {
    final provider =
        Provider.of<CommonProvider>(indexKey.currentContext!, listen: false);
    final feeds = provider.feeds;
    if (feeds.isEmpty) {
      return provider.getEntryFeed();
    } else {
      return;
    }
  }

  // Reset form
  void resetEntryForm() {
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
      _unitTextController.clear();
      _otherPurposeCtrl.clear(); // NEW

      selectedPurpose = null;
      totalPerson = null;

      _image = null;

      // Multi-select units
      selectedUnits.clear();
      unitsString = "";
    });

    Provider.of<UnitProvider>(context, listen: false).clearUnitList();
    FocusScope.of(context).unfocus();
  }

  // UI helpers
  Widget _buildModeOption({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_on : Icons.radio_button_off,
              color: CColors.brand1,
              size: 22,
            ),
            const SizedBox(width: 6),
            textBlue(label),
          ],
        ),
      ),
    );
  }

  // Camera
  Future getCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Unit chips (special site)
  void _addCustomUnit(String unit) {
    if (unit.trim().isNotEmpty && !selectedUnits.contains(unit.trim())) {
      setState(() {
        selectedUnits.add(unit.trim());
        unitsString = selectedUnits.join(", ");
        _unitTextController.clear();
      });
    }
  }

  void _removeUnit(String unit) {
    setState(() {
      selectedUnits.remove(unit);
      unitsString = selectedUnits.join(", ");
    });
  }

  // ---------- BUILD ----------
  final unitkey = GlobalKey();

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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildModeOption(
                        selected: type,
                        label: "Vehicle",
                        onTap: () {
                          setState(() {
                            type = true;
                            resetEntryForm();
                            Provider.of<CommonProvider>(
                                    indexKey.currentContext!,
                                    listen: false)
                                .getEntryFeed();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildModeOption(
                        selected: !type,
                        label: "Walk In",
                        onTap: () {
                          setState(() {
                            type = false;
                            resetEntryForm();
                            vehicleNo.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Consumer<CommonProvider>(
                  builder: (_, provd, __) {
                    return type == false
                        ? walkInEntry()
                        : feedEntry(provd.feeds);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- VEHICLE (FEED) ENTRY UI ----------
  Widget feedEntry(List list) {
    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];

    return list.isEmpty
        ? SizedBox(
            height: 400,
            child: Center(
              child: Consumer<CommonProvider>(
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
              ),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: vechicleImage(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Consumer<CommonProvider>(
                      builder: (_, provd, __) {
                        DateTime date = DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse(provd.feeds[provd.feedIndex]['date_time']);
                        return provd.blockedVehicle == 1
                            ? textRed("!Black Listed Vehicle!")
                            : text18(
                                "Feed Entry Time: ${DateFormat('dd MMM hh:mm a').format(date)}");
                      },
                    ),
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
                                  contentPadding:
                                      const EdgeInsets.only(left: 18),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Consumer<CommonProvider>(
                          builder: (_, provd, __) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: provd.commonLoading
                                  ? loading50Button()
                                  : buttonWidth(
                                      "Skip",
                                      () {
                                        mobileControl.clear();
                                        nameControl.clear();
                                        icNumberCont.clear();
                                        contactPerson.clear();
                                        emailControl.clear();
                                        unitNumberCont.clear();
                                        companyNoControl.clear();
                                        passNoControl.clear();
                                        selectedPurpose = null;
                                        totalPerson = null;
                                        _otherPurposeCtrl.clear(); // NEW
                                        Provider.of<CommonProvider>(context,
                                                listen: false)
                                            .incrementFeedIndex();
                                      },
                                      MediaQuery.of(context).size.width / 2 -
                                          100,
                                    ),
                            );
                          },
                        ),
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
                            controller: mobileControl,
                            style: FFonts.formFont,
                            decoration: InputDecoration(
                              label: const Text("Mobile"),
                              labelStyle: FFonts.labelStyle,
                              counterText: "",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.only(left: 18),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide:
                                    BorderSide(width: 1, color: CColors.shade1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide:
                                    BorderSide(width: 1, color: CColors.shade1),
                              ),
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
                          final items = provd.purpose;
                          final currentId = selectedPurpose != null
                              ? selectedPurpose['purpose_id']
                              : null;
                          final hasCurrent = currentId != null &&
                              items.any((e) => e['purpose_id'] == currentId);

                          return Container(
                            key: unitkey,
                            height: 50,
                            padding: const EdgeInsets.only(left: 12),
                            width: MediaQuery.of(context).size.width - 136,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: CColors.shade1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              dropdownColor: CColors.dark,
                              style: FFonts.formFont,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6),
                                filled: false,
                                hintText: "Purpose of Visit",
                              ),
                              value: hasCurrent ? currentId : null,
                              items: items.map<DropdownMenuItem<int>>((item) {
                                return DropdownMenuItem<int>(
                                  value: item['purpose_id'] as int,
                                  child: textProfile(item['purpose']),
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  selectedPurpose = items.firstWhere(
                                      (e) => e['purpose_id'] == newVal);
                                  if (!_isOtherPurpose())
                                    _otherPurposeCtrl.clear();
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // NEW: Other purpose text field (visible only when Other)
                    if (_isOtherPurpose())
                      authField("Specify other purpose", _otherPurposeCtrl, 150,
                          TextInputType.text, TextCapitalization.words),

                    const SizedBox(height: 24),

                    // ALWAYS render the rest (per your request)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
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
                                  BorderSide(width: 1, color: CColors.shade1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide:
                                  BorderSide(width: 1, color: CColors.shade1),
                            ),
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
                                height: 100,
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
                          },
                        ),
                      );
                    }),
                    authField("Name", nameControl, 50, TextInputType.text,
                        TextCapitalization.words),

                    if (currentLocationId != "26f697c540f2015daf77f4a")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: authField(
                              "IC Number",
                              icNumberCont,
                              9,
                              TextInputType.text,
                              TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Provider.of<BarcodeProvider>(context,
                                      listen: false)
                                  .scanBarcode()
                                  .then((value) {
                                if (!mounted || value.isEmpty) return;
                                setState(() => icNumberCont.text = value);
                                FocusScope.of(context).unfocus();
                              });
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CColors.brand1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Image(
                                image: AssetImage('assets/images/barcode.png'),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    authField("Company Name", companyNoControl, 100,
                        TextInputType.visiblePassword, TextCapitalization.none),
                    authField("V pass / C pass", passNoControl, 100,
                        TextInputType.visiblePassword, TextCapitalization.none),
                    authField("E-Mail", emailControl, 100,
                        TextInputType.emailAddress, TextCapitalization.none),
                    if (_shouldShowContactPersonField(isWalkIn: false))
                      authField(_getContactPersonLabel(), contactPerson, 100,
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
                                const BorderRadius.all(Radius.circular(12)),
                          ),
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
                            onChanged: (newVal) =>
                                setState(() => totalPerson = newVal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save / Clear
                    _savingVehicle
                        ? loading50Button()
                        : Row(
                            children: [
                              SizedBox(
                                child: buttonWidth(
                                  "Save",
                                  () async {
                                    setState(() => _savingVehicle = true);
                                    try {
                                      await entryFunction();
                                    } finally {
                                      if (mounted)
                                        setState(() => _savingVehicle = false);
                                    }
                                  },
                                  MediaQuery.of(context).size.width / 3 * 2 -
                                      16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                child: buttonWidth(
                                  "Clear",
                                  () => resetEntryForm(),
                                  MediaQuery.of(context).size.width / 3 - 16,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 180),
            ],
          );
  }

  // ---------- WALK-IN UI ----------
  Widget walkInEntry() {
    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: _image != null
                            ? Align(
                                alignment: Alignment.center,
                                child:
                                    Image.file(_image!, fit: BoxFit.fitWidth))
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
                        // Vehicle (optional in walk-in; keep)
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
                                        width: 1, color: CColors.shade1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Mobile (base for walk-in)
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
                                        width: 1, color: CColors.shade1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                        width: 1, color: CColors.shade1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Purpose
              Row(
                children: [
                  SizedBox(width: 100, child: textDesc("Purpose")),
                  const SizedBox(width: 12),
                  Consumer<CommonProvider>(builder: (_, provd, __) {
                    final items = provd.purpose;
                    final currentId = selectedPurpose != null
                        ? selectedPurpose['purpose_id']
                        : null;
                    final hasCurrent = currentId != null &&
                        items.any((e) => e['purpose_id'] == currentId);

                    return Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 12),
                      width: MediaQuery.of(context).size.width - 136,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: CColors.shade1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        dropdownColor: CColors.dark,
                        style: FFonts.formFont,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          filled: false,
                          hintStyle: FFonts.formFont,
                          hintText: "Purpose of Visit",
                        ),
                        value: hasCurrent ? currentId : null,
                        items: items.map<DropdownMenuItem<int>>((item) {
                          return DropdownMenuItem<int>(
                            value: item['purpose_id'] as int,
                            child: textProfile(item['purpose']),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            selectedPurpose = items
                                .firstWhere((e) => e['purpose_id'] == newVal);
                            if (!_isOtherPurpose()) _otherPurposeCtrl.clear();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              // NEW: Other purpose text field
              if (_isOtherPurpose())
                authField("Specify other purpose", _otherPurposeCtrl, 150,
                    TextInputType.text, TextCapitalization.words),

              const SizedBox(height: 16),

              // ALWAYS render full details (per your request)
              authField("Name", nameControl, 50, TextInputType.text,
                  TextCapitalization.words),

              // Special site multi-unit selector block
              if (currentLocationId == "64f1d7a46fbcc7432ee4889c")
                Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: CColors.shade1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitTextController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 16),
                                hintText: "Type or select unit number",
                                hintStyle: TextStyle(color: CColors.light),
                              ),
                              onFieldSubmitted: (value) =>
                                  _addCustomUnit(value),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: CColors.brand1),
                            onPressed: () =>
                                _addCustomUnit(_unitTextController.text),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down,
                                color: CColors.light),
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: "header",
                                  child: Text("Select Unit:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const PopupMenuDivider(),
                                ...allUnits.map((unit) {
                                  return PopupMenuItem(
                                      value: unit, child: Text(unit));
                                }).toList(),
                              ];
                            },
                            onSelected: (value) {
                              if (value != "header") _addCustomUnit(value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedUnits.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedUnits.length,
                          itemBuilder: (context, index) {
                            final unit = selectedUnits[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: CColors.brand1,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(unit,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _removeUnit(unit),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                )
              else
                Padding(
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(width: 1, color: CColors.shade1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(width: 1, color: CColors.shade1),
                        ),
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
                    },
                  ),
                );
              }),
              if (currentLocationId != "26f697c540f2015daf77f4a")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: authField("IC Number", icNumberCont, 50,
                          TextInputType.text, TextCapitalization.characters),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Provider.of<BarcodeProvider>(context, listen: false)
                            .scanBarcode()
                            .then((value) {
                          if (!mounted || value.isEmpty) return;
                          setState(() => icNumberCont.text = value);
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
                    ),
                  ],
                ),
              authField("Company Name", companyNoControl, 100,
                  TextInputType.visiblePassword, TextCapitalization.none),
              authField("V pass / C pass", passNoControl, 100,
                  TextInputType.visiblePassword, TextCapitalization.none),
              authField("E-mail", emailControl, 100, TextInputType.emailAddress,
                  TextCapitalization.none),
              if (_shouldShowContactPersonField(isWalkIn: true))
                authField(_getContactPersonLabel(), contactPerson, 100,
                    TextInputType.text, TextCapitalization.words),
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
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
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
                      onChanged: (newVal) =>
                          setState(() => totalPerson = newVal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save / Clear
              _savingWalkIn
                  ? loading50Button()
                  : Row(
                      children: [
                        SizedBox(
                          child: buttonWidth(
                            "Save",
                            () async {
                              setState(() => _savingWalkIn = true);
                              try {
                                await walkIn(currentLocationId);
                              } finally {
                                if (mounted)
                                  setState(() => _savingWalkIn = false);
                              }
                            },
                            MediaQuery.of(context).size.width / 3 * 2 - 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          child: buttonWidth(
                            "Clear",
                            () => resetEntryForm(),
                            MediaQuery.of(context).size.width / 3 - 16,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 180),
      ],
    );
  }

  // ---------- ACTIONS ----------
  Future<void> entryFunction() async {
    final err = validateFormUnified(isWalkIn: false);
    if (err != null) {
      notif('Failed', err);
      return;
    }

    final isOther = _isOtherPurpose();

    // NOTE: do NOT blank other fields — send whatever user filled

    final cp = Provider.of<CommonProvider>(context, listen: false);
    final currentLocationId = cp.locations[cp.selectedLocation]['location_id'];

    Map<String, String> data = {};
    data.addAll({"vehicle_no": vehicleNo.text});
    data.addAll({"name": nameControl.text});
    data.addAll({"mobile_no": mobileControl.text});
    data.addAll({"email": emailControl.text});
    data.addAll({"contact_person": contactPerson.text});
    data.addAll({
      "ic_number": currentLocationId == "26f697c540f2015daf77f4a"
          ? ""
          : icNumberCont.text,
    });
    data.addAll({"unit_no": unitNumberCont.text});
    data.addAll({"company_no": companyNoControl.text});
    data.addAll({"pass_no": passNoControl.text});
    data.addAll({"no_of_person": totalPerson?.toString() ?? ""});

    data.addAll({"purpose_visit": selectedPurpose['purpose_id'].toString()});
    data.addAll({"other": isOther ? _otherPurposeCtrl.text.trim() : ""});

    data.addAll({"in_time": DateTime.now().toString()});

    await Provider.of<CommonProvider>(context, listen: false).addEntry(data);
  }

  Future<void> walkIn(String currentLocationId) async {
    // Special site validations
    if (currentLocationId == "64f1d7a46fbcc7432ee4889c") {
      if (mobileControl.text.trim().isEmpty) {
        notif('Failed', "Kindly enter mobile number");
        return;
      } else if (mobileControl.text.trim().length < 8) {
        notif('Failed', "Kindly check your mobile number");
        return;
      } else if (selectedPurpose == null) {
        notif('Failed', "Kindly select the purpose");
        return;
      }

      if (_isOtherPurpose()) {
        if (_otherPurposeCtrl.text.trim().isEmpty) {
          notif('Failed', "Kindly specify the other purpose");
          return;
        }
      } else {
        if (nameControl.text.trim().isEmpty) {
          notif('Failed', "Kindly enter visitor name");
          return;
        } else if (totalPerson == null) {
          notif('Failed', "Kindly select number of visitors");
          return;
        }
        if (_isContractPurpose() && contactPerson.text.trim().isEmpty) {
          notif('Failed', "Kindly enter Purpose of Contractor");
          return;
        }
      }
    } else {
      final err = validateFormUnified(isWalkIn: true);
      if (err != null) {
        notif('Failed', err);
        return;
      }
    }

    final isOther = _isOtherPurpose();

    // NOTE: do NOT blank other fields — send whatever user filled
    var data = {
      "vehicle_no": vehicleNo.text,
      "mobile_no": mobileControl.text,
      "name": nameControl.text,
      "ic_number": currentLocationId == "26f697c540f2015daf77f4a"
          ? ""
          : icNumberCont.text,
      "contact_person": contactPerson.text,
      "email": emailControl.text,
      "no_of_person": totalPerson?.toString() ?? "",
      "company_no": companyNoControl.text,
      "pass_no": passNoControl.text,
      "purpose_visit": selectedPurpose['purpose_id'].toString(),
      "other": isOther ? _otherPurposeCtrl.text.trim() : "",
      "in_time": DateTime.now().toString(),
      "location_id": Provider.of<CommonProvider>(indexKey.currentContext!,
                  listen: false)
              .locations[
          Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
              .selectedLocation]['location_id'],
      "unit_no": (currentLocationId == "64f1d7a46fbcc7432ee4889c"
          ? unitsString
          : unitNumberCont.text),
      "image_capture":
          _image != null ? base64Encode(_image!.readAsBytesSync()) : "",
    };

    print('Payload $data');
    return storeWalkInEntry(data);
  }

  Future<void> storeWalkInEntry(var data) async {
    Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .loadingOn();
    final value = await ApiService()
        .post(indexKey.currentContext!, "walkIn_entry", params: data);
    Provider.of<CommonProvider>(indexKey.currentContext!, listen: false)
        .loadingOff();
    print(value);
    if (value['status'] == "success") {
      resetEntryForm();
      return notif('Success', value["message"]);
    } else {
      return notif('Failed', value["message"]);
    }
  }
}

// ---------- GLOBAL CONTROLLERS (as in your original) ----------
TextEditingController nameControl = TextEditingController();
TextEditingController vehicleNo = TextEditingController();
TextEditingController mobileControl = TextEditingController();
TextEditingController companyNoControl = TextEditingController();
TextEditingController passNoControl = TextEditingController();
TextEditingController emailControl = TextEditingController();
TextEditingController contactPerson = TextEditingController();
TextEditingController icNumberCont = TextEditingController();
TextEditingController unitNumberCont = TextEditingController();
