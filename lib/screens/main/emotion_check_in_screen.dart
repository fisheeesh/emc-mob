import 'package:emotion_check_in_app/components/buttons/custom_elevated_button.dart';
import 'package:emotion_check_in_app/provider/emotion_check_in_provider.dart';
import 'package:emotion_check_in_app/screens/main/check_in_success_screen.dart';
import 'package:emotion_check_in_app/screens/main/home_screen.dart';
import 'package:emotion_check_in_app/utils/constants/colors.dart';
import 'package:emotion_check_in_app/utils/constants/sizes.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:emotion_check_in_app/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmotionCheckInScreen extends StatefulWidget {
  final String userName;
  final DateTime checkInTime;

  const EmotionCheckInScreen({
    super.key,
    required this.userName,
    required this.checkInTime,
  });

  @override
  State<EmotionCheckInScreen> createState() => _EmotionCheckInScreenState();
}

class _EmotionCheckInScreenState extends State<EmotionCheckInScreen> {
  /// Tracks the selected tab (0: Negative, 1: Neutral, 2: Positive)
  int _selectedTabIndex = 0;

  /// Tracks the selected emotion (only one can be selected)
  String? _selectedEmotion;

  String? _selectedLabel;
  final TextEditingController _feelingController = TextEditingController();

  /// List of emotions for each tab
  final Map<int, List<Map<String, dynamic>>> _emotions = {
    0: [
      {'icon': '😓', 'label': 'tired'},
      {'icon': '😩', 'label': 'stressed'},
      {'icon': '😴', 'label': 'bored'},
      {'icon': '😡', 'label': 'frustrated'},
      {'icon': '😞', 'label': 'disappointed'},
      {'icon': '😭', 'label': 'sad'},
      {'icon': '😰', 'label': 'anxious'},
      {'icon': '😒', 'label': 'annoyed'},
      {'icon': '😠', 'label': 'mad'},
    ],
    1: [
      {'icon': '😐', 'label': 'neutral'},
      {'icon': '😌', 'label': 'calm'},
      {'icon': '😑', 'label': 'meh'},
      {'icon': '😶', 'label': 'indifferent'},
      {'icon': '🙂', 'label': 'okay'},
      {'icon': '😕', 'label': 'unsure'},
      {'icon': '🤔', 'label': 'curious'},
      {'icon': '🙃', 'label': 'playful'},
      {'icon': '🫤', 'label': 'uncertain'},
    ],
    2: [
      {'icon': '😀', 'label': 'happy'},
      {'icon': '😄', 'label': 'excited'},
      {'icon': '😍', 'label': 'loved'},
      {'icon': '😁', 'label': 'joyful'},
      {'icon': '🥳', 'label': 'celebratory'},
      {'icon': '😎', 'label': 'confident'},
      {'icon': '😊', 'label': 'grateful'},
      {'icon': '🤩', 'label': 'thrilled'},
      {'icon': '😇', 'label': 'peaceful'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EHelperFunctions.isIOS()
              ? const EdgeInsets.only(
                  left: 28, right: 28, top: 75)
              : const EdgeInsets.only(
                  left: ESizes.md, right: ESizes.md, top: ESizes.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// header section
              _headerSection(context),
              const SizedBox(height: 15),

              /// Tab Bar and Emoji Grid
              Container(
                padding: const EdgeInsets.all(ESizes.md),
                decoration: BoxDecoration(
                  color: EColors.white,
                  borderRadius: BorderRadius.circular(ESizes.roundedSm),
                  boxShadow: [
                    BoxShadow(
                      color: EColors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tab Bar
                    _tabBarSection(),
                    SizedBox(height: 15,),
                    // Emoji Grid
                    _emojiGridSection(),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              /// Feeling Text Field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ESizes.roundedSm),
                  boxShadow: [
                    BoxShadow(
                      color: EColors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _feelingController,
                  cursorColor: EColors.grey,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: ETexts.HINT,
                    hintStyle: TextStyle(color: EColors.grey),
                    // Border when the field is focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ESizes.roundedXs),
                      borderSide:
                          BorderSide(color: EColors.lightBlue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ESizes.roundedXs),
                      borderSide:
                          BorderSide(color: EColors.lightBlue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              /// submit button
              _submitButton(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return CustomElevatedButton(
        onPressed: _selectedEmotion != null
            ? () {
                context.read<EmotionCheckInProvider>().addCheckIn(
                      widget.userName,
                      widget.checkInTime,
                      _selectedEmotion!,
                      _selectedLabel!,
                      _feelingController.text,
                    );
                EHelperFunctions.navigateToScreen(
                    context,
                    CheckInSuccessScreen(
                      userName: widget.userName,
                      checkInTime: widget.checkInTime,
                      emoji: _selectedEmotion!,
                      label: _selectedLabel!,
                      feeling: _feelingController.text,
                    ));
                debugPrint('userName: ${widget.userName}');
                debugPrint('time: ${widget.checkInTime}');
                debugPrint('emoji: $_selectedEmotion');
                debugPrint('label: $_selectedLabel');
              }
            : null,
        placeholder: ETexts.SUBMIT);
  }

  Row _headerSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        const SizedBox(width: 10),
        Text(
          ETexts.QUES,
          style: ETextTheme.lightTextTheme.headlineMedium,
        )
      ],
    );
  }

  Widget _tabBarSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabItem(0, "Negative"),
        _buildTabItem(1, "Neutral"),
        _buildTabItem(2, "Positive"),
      ],
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;

          /// Reset selection when switching tabs
          _selectedEmotion = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? EColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: EColors.primary),
        ),
        child: Text(
          label,

          /// @TODO: Apply Google Font
          style: TextStyle(
            color: isSelected ? EColors.white : EColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _emojiGridSection() {
    final emotions = _emotions[_selectedTabIndex]!;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        final isSelected = _selectedEmotion == emotion['icon'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLabel = emotion['label'];
              _selectedEmotion = emotion['icon']; // Select emotion
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : EColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? EColors.primary : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  emotion['icon'],
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 2),
                Text(
                  emotion['label'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
