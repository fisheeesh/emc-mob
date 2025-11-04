import 'dart:io';

import 'package:emc_mob/utils/constants/text_strings.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EHelperFunctions {
  static String generateEmployeeId(int id, {String prefix = "ATA"}) {
    if (id < 1 || id > 9999) {
      throw ArgumentError("Employee ID must be between 1 and 9999");
    }
    return "$prefix-${id.toString().padLeft(4, '0')}";
  }

  static String getInitialName(String fullName) {
    if (fullName.isEmpty) return "";

    final nameParts = fullName.trim().split(" ");
    if (nameParts.isEmpty) return "";

    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }

    final firstInitial = nameParts[0].isNotEmpty
        ? nameParts[0].substring(0, 1).toUpperCase()
        : "";
    final lastInitial = nameParts[1].isNotEmpty
        ? nameParts[1].substring(0, 1).toUpperCase()
        : "";

    return "$firstInitial$lastInitial";
  }

  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return "NULL";

    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith("959") && cleaned.length == 12) {
      return "+${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}";
    }

    if (cleaned.startsWith("09")) {
      return "${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}";
    }

    if (cleaned.length > 10) {
      final countryCode = cleaned.substring(0, cleaned.length - 10);
      final rest = cleaned.substring(cleaned.length - 10);
      return "+$countryCode ${rest.substring(0, 3)} ${rest.substring(3, 6)} ${rest.substring(6)}";
    }

    return phone;
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'Not Specified';
    }

    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static String getBaseUrl() {
    return isIOS()
        ? EUrls.IOS_BASE_URL
        : EUrls.ANDROID_BASE_URL;
  }

  static double getProportionateHeight(BuildContext context, double fraction) {
    final height = MediaQuery.of(context).size.height;
    if (height > 800) return height * (fraction - 0.03);
    if (height < 700) return height * (fraction + 0.03);
    return height * fraction;
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

  static String formatJobType(String jobType) {
    switch (jobType) {
      case 'FULLTIME':
        return 'Full Time';
      case 'PARTTIME':
        return 'Part Time';
      case 'CONTRACT':
        return 'Contract';
      case 'INTERN':
        return 'Intern';
      default:
        return jobType;
    }
  }

  static String formatWorkStyle(String workStyle) {
    switch (workStyle) {
      case 'ONSITE':
        return 'On-Site';
      case 'REMOTE':
        return 'Remote';
      case 'HYBRID':
        return 'Hybrid';
      default:
        return workStyle;
    }
  }

  static String formatGender(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }
}