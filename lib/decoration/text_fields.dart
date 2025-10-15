import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utilities/color.dart';
import '../utilities/fonts.dart';

Widget authFieldPass(
        String label, TextEditingController control, bool obscure) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          controller: control,
          obscureText: obscure,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

Widget authFieldFunction(
        String label, TextEditingController control, VoidCallback function) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          inputFormatters: [
            UpperCaseTextFormatter(),
          ],
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          onEditingComplete: function,
          onChanged: (val) => function,
          controller: control,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

Widget authField(String label, TextEditingController control, int max,
        TextInputType textInputType, TextCapitalization textCapitalization) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          maxLength: max,
          controller: control,
          textCapitalization: textCapitalization,
          keyboardType: textInputType,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            counterText: "",
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );
Widget authField3(String label, TextEditingController control, int max,
        TextInputType textInputType, TextCapitalization textCapitalization) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          maxLength: max,
          controller: control,
          textCapitalization: textCapitalization,
          keyboardType: textInputType,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            counterText: "",
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

Widget authField2(String label, TextEditingController control,
        TextInputType textInputType) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          keyboardType: textInputType,
          controller: control,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

Widget authFieldDrop(String label, TextEditingController control) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          controller: control,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            suffixIcon: GestureDetector(
                onTap: () {},
                child: const Icon(Icons.arrow_drop_down,
                    color: CColors.brand1, size: 28)),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

Widget searchField(String label, TextEditingController control) => SizedBox(
      height: 50,
      child: TextFormField(
        cursorColor: CColors.shade1,
        cursorHeight: 24,
        controller: control,
        style: FFonts.formFont,
        decoration: InputDecoration(
          filled: true,
          fillColor: CColors.shade2,
          prefixIcon: const Icon(
            Icons.search,
            color: CColors.light,
          ),
          hintText: label,
          hintStyle: const TextStyle(
              color: CColors.light, fontSize: 14, fontWeight: FontWeight.w200),
          labelStyle: FFonts.labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.only(left: 18),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 1, color: CColors.shade1)),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 1, color: CColors.shade1)),
        ),
      ),
    );

Widget attendanceField(String label, TextEditingController control) => SizedBox(
      height: 50,
      child: TextFormField(
        cursorColor: CColors.shade1,
        cursorHeight: 24,
        controller: control,
        style: FFonts.formFont,
        decoration: InputDecoration(
          filled: true,
          fillColor: CColors.shade2,
          prefixIcon: const Icon(
            Icons.search,
            color: CColors.light,
          ),
          hintText: label,
          hintStyle: const TextStyle(
              color: CColors.light, fontSize: 14, fontWeight: FontWeight.w200),
          labelStyle: FFonts.labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.only(left: 18),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 1, color: CColors.shade1)),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 1, color: CColors.shade1)),
        ),
      ),
    );

Widget searchFieldWeb(
        BuildContext context, String label, TextEditingController control) =>
    SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width > 1024
          ? 350
          : MediaQuery.of(context).size.width / 2.92,
      child: TextFormField(
        cursorColor: CColors.shade1,
        cursorHeight: 24,
        controller: control,
        style: FFonts.formFont,
        decoration: InputDecoration(
          filled: true,
          fillColor: CColors.shade2,
          prefixIcon: const Icon(
            Icons.search,
            color: CColors.light,
          ),
          hintText: label,
          hintStyle: const TextStyle(
              color: CColors.light, fontSize: 14, fontWeight: FontWeight.w200),
          labelStyle: FFonts.labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.only(left: 18),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 0.05, color: CColors.light)),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(width: 1, color: CColors.shade1)),
        ),
      ),
    );

Widget formField2(String label, TextEditingController control) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade2,
          cursorHeight: 24,
          controller: control,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade2)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade2)),
          ),
        ),
      ),
    );

Widget authFieldEntry(String label, TextEditingController control) => Container(
      height: 70,
      width: 650,
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          controller: control,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 18),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );
Widget authParagraph(String label, TextEditingController control,
        TextInputType textInputType, TextCapitalization textCapitalization) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 50,
        child: TextField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          maxLines: 2,
          controller: control,
          textCapitalization: textCapitalization,
          keyboardType: textInputType,
          style: FFonts.formFont,
          decoration: InputDecoration(
            label: Text(label),
            counterText: "",
            labelStyle: FFonts.labelStyle,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );

Widget authFieldCenter(TextEditingController control) => Container(
      height: 70,
      width: 650,
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          cursorColor: CColors.shade1,
          cursorHeight: 24,
          textAlign: TextAlign.center,
          controller: control,
          style: FFonts.formFont,
          decoration: const InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.only(left: 18),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(width: 1, color: CColors.shade1)),
          ),
        ),
      ),
    );
Widget buttonAddUser(String name, VoidCallback funct) => SizedBox(
      height: 50,
      width: 130,
      child: ElevatedButton(
          style: TextButton.styleFrom(
              backgroundColor: CColors.brand1,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: funct,
          child: text14(name)),
    );
