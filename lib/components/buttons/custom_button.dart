import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.width,
    required this.height,
    this.onPressed,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ESizes.roundedXs),
          ),
        ),

        /// Let us design as we want
        child: child,
      ),
    );
  }
}
