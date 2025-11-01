import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    required this.width,
    required this.height,
    this.onPressed,
    this.borderColor = EColors.black,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;
  final void Function()? onPressed;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ESizes.roundedXs),
          ),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: child,
      ),
    );
  }
}