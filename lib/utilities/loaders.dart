import 'package:flutter/material.dart';

import 'color.dart';

loading50Button() => const Center(
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2,
            backgroundColor: CColors.brand1,
          ),
        ),
      ),
    );
