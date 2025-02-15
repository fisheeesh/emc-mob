import 'package:emotion_check_in_app/components/buttons/custom_elevated_button.dart';
import 'package:emotion_check_in_app/provider/check_in_provider.dart';
import 'package:emotion_check_in_app/screens/main/check_in_success_screen.dart';
import 'package:emotion_check_in_app/utils/constants/colors.dart';
import 'package:emotion_check_in_app/utils/constants/sizes.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:emotion_check_in_app/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmotionCheckInScreen extends StatefulWidget {
  final String userName;

  const EmotionCheckInScreen({
    super.key,
    required this.userName,
  });

  @override
  State<EmotionCheckInScreen> createState() => _EmotionCheckInScreenState();
}

class _EmotionCheckInScreenState extends State<EmotionCheckInScreen> {
  /// Tracks the selected tab (0: Negative, 1: Neutral, 2: Positive)
  int _selectedTabIndex = 1;

  /// Tracks the selected emotion (only one can be selected)
  String? _selectedEmotion;

  String? _selectedLabel;
  final TextEditingController _feelingController = TextEditingController();

  bool isLoading = false;

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
  static const int _maxCharacters = 100;
  int _currentCharacterCount = 0;

  @override
  void initState() {
    super.initState();
    _feelingController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _feelingController.removeListener(_updateCharacterCount);
    _feelingController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _currentCharacterCount = _feelingController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).size.height * (EHelperFunctions.isIOS() ? 0.07 : 0.05);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                    left: ESizes.md, right: ESizes.md, top: topPadding),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _tabBarSection(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Emoji Grid
                      _emojiGridSection(),
                    ],
                  ),
                ),
                SizedBox(height: EHelperFunctions.isIOS() ? 20 : 15),

                /// Feeling Text Field
                _feelingTextField(),

                SizedBox(height: EHelperFunctions.isIOS() ? 20 : 15),
                /// submit button
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Feeling Text Field with Character Counter
  Widget _feelingTextField() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _feelingController,
            cursorColor: EColors.grey,
            maxLines: 3,
            maxLength: _maxCharacters,
            decoration: InputDecoration(
              hintText: ETexts.HINT,
              counterText: '',
              hintStyle: GoogleFonts.lexend(
                textStyle: TextStyle(color: EColors.grey, fontSize: 16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ESizes.roundedXs),
                borderSide: BorderSide(color: EColors.lightBlue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ESizes.roundedXs),
                borderSide: BorderSide(color: EColors.lightBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 5),

          /// Real-time Character Counter
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$_currentCharacterCount/$_maxCharacters",
              style: TextStyle(
                color: _currentCharacterCount >= 90 ? EColors.danger : EColors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomElevatedButton(
      onPressed: _selectedEmotion != null && !isLoading
          ? () async {
              setState(() => isLoading = true);

              var isSuccess = await context.read<CheckInProvider>().sendCheckIn(
                    context,
                    _selectedLabel!,
                    _feelingController.text,
                  );

              setState(() => isLoading = false);

              if (isSuccess) {
                EHelperFunctions.navigateToScreen(
                  context,
                  CheckInSuccessScreen(
                    userName: widget.userName,
                    checkInTime: DateTime.now(),
                    emoji: _selectedEmotion!,
                    label: _selectedLabel!,
                    feeling: _feelingController.text,
                  ),
                );
              }
            }
          : null,
      placeholder: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ETexts.SUBMITTING,
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: EColors.white,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              ETexts.SUBMIT,
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

  Row _headerSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Color(0xFFBAD6FE), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(0, "Negative", isFirst: true),
          _buildTabItem(1, "Neutral"),
          _buildTabItem(2, "Positive", isLast: true),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, {bool isFirst = false, bool isLast = false}) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _selectedEmotion = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFBAD6FE) : Color(0xFFF7F8F8),
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(20) : Radius.zero,
              right: isLast ? const Radius.circular(20) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: isSelected ? Color(0xFF3085FE) : Color(0xFF87878B),
                fontSize: 12,
              )
            ),
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
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1.1,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        final isSelected = _selectedEmotion == emotion['icon'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLabel = emotion['label'];
              _selectedEmotion = emotion['icon'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : EColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? EColors.primary : Colors.transparent,
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
