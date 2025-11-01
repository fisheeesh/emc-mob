import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.placeholder,
  });

  final void Function()? onPressed;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ESizes.roundedLg),
          ),
          minimumSize: const Size.fromHeight(100),
        ),
        child: placeholder,
      ),
    );
  }
}
