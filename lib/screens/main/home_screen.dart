import 'package:emc_mob/components/buttons/custom_elevated_button.dart';
import 'package:emc_mob/providers/check_in_provider.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/screens/main/emotion_check_in_screen.dart';
import 'package:emc_mob/screens/main/profile_screen.dart';
import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:emc_mob/utils/constants/text_strings.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:emc_mob/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CheckInProvider>(context, listen: false).loadCheckInsFromDB();
  }

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  /// Greet to users according to time zone
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return ETexts.MORNING;
    } else if (hour >= 12 && hour < 17) {
      return ETexts.NOON;
    } else if (hour >= 17 && hour < 21) {
      return ETexts.EVENING;
    } else {
      return ETexts.NIGHT;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkInProvider = context.watch<CheckInProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final userName = loginProvider.userName ?? "Guest";
    double topPadding =
        MediaQuery.of(context).size.height *
            (EHelperFunctions.isIOS() ? 0.07 : 0.05);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: ESizes.md,
          right: ESizes.md,
          top: topPadding,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Greeting and Settings Button
            _headerSection(userName, context),
            const SizedBox(height: 20),

            /// Calendar
            _calendarSection(checkInProvider),
            const SizedBox(height: 20),

            /// Check In Information
            _checkInInfoSection(checkInProvider),
            const Spacer(),

            /// Check In Button
            _checkInButton(checkInProvider, userName),
          ],
        ),
      ),
    );
  }

  Widget _checkInButton(CheckInProvider checkInProvider, String userName) {
    return CustomElevatedButton(
      onPressed: checkInProvider.todayCheckIn != null
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmotionCheckInScreen(userName: userName),
          ),
        );
      },
      placeholder: Text(
        ETexts.CHECK_IN,
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

  Widget _checkInInfoSection(CheckInProvider checkInProvider) {
    final selectedDayCheckIn = checkInProvider.getCheckInByDate(_selectedDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(ESizes.roundedSm),
        boxShadow: [
          BoxShadow(color: EColors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: selectedDayCheckIn != null
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  right: 10,
                  left: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.login,
                  color: EColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ETexts.CHECK_IN,
                    style: ETextTheme.lightTextTheme.titleMedium,
                  ),
                  Text(
                    EHelperFunctions.getFormattedDate(
                      selectedDayCheckIn.createdAt,
                      'MMMM d, yyyy',
                    ),
                    style: ETextTheme.lightTextTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              _showCheckInDetailsModal(context, selectedDayCheckIn);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Details',
              style: ETextTheme.lightTextTheme.titleMedium?.copyWith(
                decoration: TextDecoration.underline,
                color: EColors.black,
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Text(
          ETexts.NO_CHECK_IN,
          style: ETextTheme.lightTextTheme.labelLarge,
        ),
      ),
    );
  }

  void _showCheckInDetailsModal(BuildContext context, dynamic checkIn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: EColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ESizes.roundedSm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date and Time
                Text(
                  EHelperFunctions.getFormattedDate(
                    checkIn.createdAt,
                    'MMMM d, yyyy',
                  ),
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: EColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(checkIn.createdAt),
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: EColors.dark.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Emoji
                Text(
                  checkIn.emoji,
                  style: const TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Text Feeling
                Text(
                  checkIn.textFeeling.isNotEmpty
                      ? checkIn.textFeeling
                      : 'No description',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: EColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Close Button - aligned to the right
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EColors.primary,
                      side: BorderSide(color: EColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: EColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _calendarSection(CheckInProvider checkInProvider) {
    /// Convert to Set for quick lookups
    final checkInDates = checkInProvider.checkIns
        .map(
          (checkIn) => DateTime(
        checkIn.createdAt.year,
        checkIn.createdAt.month,
        checkIn.createdAt.day,
      ),
    )
        .toSet();

    return Container(
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(ESizes.roundedSm),
        boxShadow: [
          BoxShadow(color: EColors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ESizes.sm),
        child: TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: EColors.dark,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: EColors.dark),
            rightChevronIcon: Icon(Icons.chevron_right, color: EColors.dark),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: const TextStyle(color: EColors.dark),
            weekendTextStyle: const TextStyle(color: EColors.dark),

            /// No default highlight
            todayDecoration: const BoxDecoration(),

            /// No highlight by default
            selectedDecoration: const BoxDecoration(),

            /// No range highlight
            rangeHighlightColor: Colors.transparent,

            /// No default markers
            markerDecoration: const BoxDecoration(),
            cellMargin: const EdgeInsets.all(4),
          ),
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, checkInDates);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildHighlightedDay(day, EColors.lightBlue);
            },
            todayBuilder: (context, day, focusedDay) {
              final hasCheckIn = checkInDates.contains(
                DateTime(day.year, day.month, day.day),
              );
              return _buildTodayHighlight(day, hasCheckIn);
            },
          ),
        ),
      ),
    );
  }

  /// Handles highlighting for regular days (check-in days only)
  Widget _buildDayCell(DateTime day, Set<DateTime> checkInDates) {
    if (checkInDates.contains(DateTime(day.year, day.month, day.day))) {
      return _buildHighlightedDay(day, EColors.onTimeColor);
    }

    return Center(
      child: Text('${day.day}', style: const TextStyle(color: EColors.dark)),
    );
  }

  /// Generic method to highlight selected or check-in days
  Widget _buildHighlightedDay(DateTime day, Color color) {
    return Center(
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: EColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Custom highlight for today's date (stroke if no check-in, filled if check-in exists)
  Widget _buildTodayHighlight(DateTime day, bool hasCheckIn) {
    return Center(
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: hasCheckIn ? EColors.onTimeColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: EColors.onTimeColor,

            /// Stroke only if no check-in data
            width: hasCheckIn ? 0 : 2,
          ),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              color: EColors.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Row _headerSection(String userName, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreetingMessage(),
              style: ETextTheme.lightTextTheme.headlineMedium,
            ),
            Text(userName, style: ETextTheme.lightTextTheme.labelLarge),
          ],
        ),
        _settingsButton(context),
      ],
    );
  }

  /// Settings button to navigate to profile screen
  IconButton _settingsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.settings,
        color: EColors.dark,
        size: 28,
      ),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: EColors.lightGary, width: 1.5),
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}