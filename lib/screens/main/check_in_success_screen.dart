import 'package:emc_mob/components/buttons/custom_elevated_button.dart';
import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:emc_mob/utils/constants/text_strings.dart';
import 'package:emc_mob/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckInSuccessScreen extends StatelessWidget {
  final String userName;
  final DateTime checkInTime;
  final String emoji;
  final String label;
  final String feeling;

  const CheckInSuccessScreen({
    super.key,
    required this.userName,
    required this.checkInTime,
    required this.emoji,
    required this.label,
    required this.feeling,
  });

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Padding(
        padding: EdgeInsets.only(
          left: ESizes.md,
          right: ESizes.md,
          top: topPadding,
          bottom: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            /// Checkmark Icon
            _successIcon(),
            const SizedBox(height: 20),

            /// Success Message
            _successMsg(),
            const SizedBox(height: 40),

            /// User check-in info
            _checkInInfoCard(),
            const Spacer(),

            /// Back to Home Button
            _backToHomButton(context),
          ],
        ),
      ),
    );
  }

  Container _checkInInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ESizes.md),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(ESizes.roundedSm),
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Time
          Text(ETexts.TIME, style: ETextTheme.lightTextTheme.labelMedium),
          const SizedBox(height: 10),
          Text(
            DateFormat('h:mm a').format(checkInTime),
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: EColors.dark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          /// Emoji and Emotion Text
          Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 40)),

              Text(label, style: ETextTheme.lightTextTheme.labelLarge),
              const SizedBox(height: 20),

              /// Feeling Text
              Text(
                feeling.isNotEmpty ? feeling : 'No text provided',
                textAlign: TextAlign.center,
                style: ETextTheme.lightTextTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text _successMsg() {
    return Text(
      ETexts.SUCCESS_MSG,
      style: ETextTheme.lightTextTheme.headlineMedium,
    );
  }

  Container _successIcon() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFD8EBE8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: EColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: ESizes.iconXl,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _backToHomButton(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      placeholder: Text(
        ETexts.HOME,
        style: GoogleFonts.lexend(
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: EColors.white,
          ),
        ),
      ),
    );
  }
}
