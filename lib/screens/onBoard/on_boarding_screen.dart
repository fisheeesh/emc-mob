import 'package:emotion_check_in_app/components/buttons/custom_button.dart';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/utils/constants/colors.dart';
import 'package:emotion_check_in_app/utils/constants/image_strings.dart';
import 'package:emotion_check_in_app/utils/constants/sizes.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:emotion_check_in_app/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  /// controller to keep track of the current page
  final PageController _pageController = PageController();

  /// to check if the user is on the last page
  bool onLastPage = false;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _storeOnBoardInfo() async {
    int isViewed = 0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt('onBoard', isViewed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Phone Cover
          _phoneCoverSection(),

          /// Full logo
          _logoSection(),

          /// PageView positioned in the middle
          _pageViewSection(),

          /// Bottom Sheet
          _bottomSheetSection(context)
        ],
      ),
    );
  }

  Align _bottomSheetSection(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: ESizes.hMd,
        width: ESizes.wFull,
        decoration: BoxDecoration(
          color: EColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ESizes.roundedMd),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // smooth page indicator
            _smoothIndicator(),

            Column(
              children: [
                _titleSection(),
                _subTitleSection(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ESizes.md),
              child: onLastPage
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _arrowBackButton(),
                        const SizedBox(width: 10),
                        _toLogInPageButton(context)
                      ],
                    )
                  : _nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  CustomButton _nextButton() {
    return CustomButton(
        width: ESizes.wFull,
        height: ESizes.hNormal,
        child: Text(
          ETexts.NEXT,
          style: ETextTheme.lightTextTheme.titleLarge,
        ),
        onPressed: () {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        });
  }

  CustomButton _toLogInPageButton(BuildContext context) {
    return CustomButton(
      width: EHelperFunctions.isIOS() ? 280 : 298,
      height: ESizes.hNormal,
      child: Text(
        ETexts.LOGIN,
        style: ETextTheme.lightTextTheme.titleLarge,
      ),
      onPressed: () async {
        await _storeOnBoardInfo();
        EHelperFunctions.navigateToScreen(context, LoginScreen());
      },
    );
  }

  SizedBox _arrowBackButton() {
    return SizedBox(
      width: ESizes.wNormal,
      height: ESizes.hNormal,
      child: TextButton(
        onPressed: () {
          _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        },
        style: TextButton.styleFrom(
          backgroundColor: EColors.lightBlue,
          shape: CircleBorder(),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: ESizes.xs),
          child: Icon(
            Icons.arrow_back_ios,
            size: ESizes.iconMd,
            color: EColors.lightGary,
          ),
        ),
      ),
    );
  }

  Padding _subTitleSection() {
    return Padding(
      padding: const EdgeInsets.only(top: ESizes.sm, bottom: ESizes.sm),
      child: Text(
        onLastPage ? ETexts.ONBOARDINGSUBTITLE2 : ETexts.ONBOARDINGSUBTITLE1,
        key: ValueKey<bool>(onLastPage),
        style: ETextTheme.lightTextTheme.labelLarge,
      ),
    );
  }

  Padding _titleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ESizes.md),
      child: Text(
        onLastPage ? ETexts.ONBOARDINGTITLE2 : ETexts.ONBOARDINGTITLE1,
        key: ValueKey<bool>(onLastPage),
        textAlign: TextAlign.center,
        style: ETextTheme.lightTextTheme.headlineLarge,
      ),
    );
  }

  SmoothPageIndicator _smoothIndicator() {
    return SmoothPageIndicator(
        onDotClicked: (index) => _pageController.animateToPage(index,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOut),
        effect: ExpandingDotsEffect(
          activeDotColor: EColors.activeDotColor,
          dotColor: EColors.dotColor,
          dotHeight: 5,
          dotWidth: 16,
        ),
        controller: _pageController,
        count: 2);
  }

  Padding _pageViewSection() {
    return Padding(
      padding: const EdgeInsets.only(
          left: ESizes.lg, right: ESizes.lg, top: ESizes.xxxl),
      child: SizedBox(
        height: ESizes.hLg,
        width: ESizes.wLg,
        child: PageView(
          onPageChanged: (index) => {
            setState(() {
              onLastPage = (index == 1);
            })
          },
          controller: _pageController,
          children: [
            Image.asset(EImages.onBoardingPage1),
            Image.asset(EImages.onBoardingPage2),
          ],
        ),
      ),
    );
  }

  Padding _logoSection() {
    return Padding(
      padding: const EdgeInsets.only(
          top: ESizes.xl, left: ESizes.xl, right: ESizes.xl),
      child: Align(
        alignment: Alignment.topCenter,
        child: Image.asset(
          EImages.ataLogo,
        ),
      ),
    );
  }

  Padding _phoneCoverSection() {
    return Padding(
      padding: const EdgeInsets.only(top: ESizes.xl),
      child: Center(
        child: Image.asset(
          EImages.phone,
        ),
      ),
    );
  }
}
