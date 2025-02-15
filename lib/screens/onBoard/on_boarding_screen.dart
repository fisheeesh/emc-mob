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
              padding: const EdgeInsets.only(
                  left: ESizes.md, right: ESizes.md, bottom: ESizes.sm),
              child: onLastPage
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _arrowBackButton(),
                        const SizedBox(width: 10),
                        Expanded(child: _toLogInPageButton(context))
                      ],
                    )
                  : _nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
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
      onPressed: () => _goToPage(1),
    );
  }

  CustomButton _toLogInPageButton(BuildContext context) {
    return CustomButton(
      width: ESizes.wFull,
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
        onPressed: () => _goToPage(0),
        style: TextButton.styleFrom(
          backgroundColor: EColors.lightBlue,
          shape: const CircleBorder(),
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
      controller: _pageController,
      count: 2,
      onDotClicked: (index) => _goToPage(index),
      effect: const ExpandingDotsEffect(
        activeDotColor: EColors.activeDotColor,
        dotColor: EColors.dotColor,
        dotHeight: 5,
        dotWidth: 16,
      ),
    );
  }

  Padding _pageViewSection() {
    double topPadding = MediaQuery.of(context).size.height * 0.26;

    return Padding(
      padding: EdgeInsets.only(left: ESizes.lg, right: ESizes.lg, top: topPadding),
      child: SizedBox(
        height: ESizes.hLg,
        width: ESizes.wLg,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 1);
            });
          },
          children: [
            _preloadImage(EImages.onBoardingIntro1),
            _preloadImage(EImages.onBoardingIntro2),
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

  Widget _preloadImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}
