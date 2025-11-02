import 'dart:io';

import 'package:emc_mob/utils/constants/text_strings.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EHelperFunctions {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String getBaseUrl() {
    return isIOS()
        ? EUrls.IOS_BASE_URL
        : EUrls.BASE_URL;
  }

  static double getProportionateHeight(BuildContext context, double fraction) {
    final height = MediaQuery.of(context).size.height;
    if (height > 800) return height * (fraction - 0.03);
    if (height < 700) return height * (fraction + 0.03);
    return height * fraction;
  }

  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(ETexts.OK))
            ],
          );
        });
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => screen));
  }

  static String ensureEndsWithFullStop(String text) {
    text = text.trim();
    if (text.isEmpty) return text;
    return text.endsWith('.') ? text : "$text.";
  }

  static String getFormattedDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }
}