import 'package:emc_mob/models/employee_model.dart';
import 'package:emc_mob/providers/employee_provider.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/screens/main/edit_profile_screen.dart';
import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:emc_mob/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    /// Fetch employee data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployeeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: employeeProvider.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: EColors.primary,
          strokeWidth: 3.0,
        ),
      )
          : employeeProvider.errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: EColors.danger),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 62.0),
              child: Text(
                employeeProvider.errorMessage ?? 'Unknown error',
                style: ETextTheme.lightTextTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                employeeProvider.fetchEmployeeData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : employeeProvider.employee == null
          ? const Center(child: Text('No employee data available'))
          : _buildProfileContent(employeeProvider.employee!, loginProvider),
    );
  }

  Widget _buildProfileContent(Employee employee, LoginProvider loginProvider) {
    return CustomScrollView(
      slivers: [
        /// App Bar with back button
        SliverAppBar(
          backgroundColor: EColors.white,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: EColors.dark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: EColors.dark,
            ),
          ),
          centerTitle: true,
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              /// Header section with background and avatar
              _buildHeaderSection(employee),
              const SizedBox(height: 24),

              /// Profile details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ESizes.md),
                child: Column(
                  children: [
                    _buildInfoCard(employee),
                    const SizedBox(height: 16),
                    _buildContactCard(employee),
                    const SizedBox(height: 16),
                    _buildDepartmentCard(employee),
                    const SizedBox(height: 24),
                    _buildLogoutButton(loginProvider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Header section with background, avatar, and name
  Widget _buildHeaderSection(Employee employee) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Background with "ATA" text
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFE8F4F8), EColors.white],
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.08,
                    child: Text(
                      'EMC',
                      style: GoogleFonts.lexend(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: EColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                /// Avatar
                _buildAvatar(employee),
                const SizedBox(height: 16),

                /// Name
                Text(
                  employee.fullName,
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: EColors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                /// Employee ID with status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF22C55E),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '• ${employee.accType}',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Employee ID
                Text(
                  EHelperFunctions.generateEmployeeId(employee.id),
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: EColors.dark.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),

                /// Edit button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(employee: employee),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: EColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: EColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar widget
  Widget _buildAvatar(Employee employee) {
    if (employee.avatar != null && employee.avatar!.isNotEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: EColors.primary, width: 4),
          boxShadow: [
            BoxShadow(
              color: EColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            employee.avatar!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildInitialsAvatar(employee.fullName);
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: EColors.primary, width: 4),
          boxShadow: [
            BoxShadow(
              color: EColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildInitialsAvatar(employee.fullName),
      );
    }
  }

  /// Initials avatar
  Widget _buildInitialsAvatar(String fullName) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EColors.primary, EColors.primary.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          EHelperFunctions.getInitialName(fullName),
          style: GoogleFonts.lexend(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: EColors.white,
          ),
        ),
      ),
    );
  }

  /// Info card
  Widget _buildInfoCard(Employee employee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.work_outline, 'Position', employee.position),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.business_center_outlined,
            'Job Type',
            EHelperFunctions.formatJobType(employee.jobType),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Work Style',
            EHelperFunctions.formatWorkStyle(employee.workStyle),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.person_outline,
            'Gender',
            EHelperFunctions.formatGender(employee.gender),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.cake_outlined,
            'Birthdate',
            EHelperFunctions.formatDate(employee.birthdate),
          ),
        ],
      ),
    );
  }

  /// Contact card
  Widget _buildContactCard(Employee employee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, 'Email', employee.email),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            employee.phone != null && employee.phone!.isNotEmpty
                ? EHelperFunctions.formatPhoneNumber(employee.phone!)
                : 'Not Specified',
          ),
        ],
      ),
    );
  }

  /// Department card
  Widget _buildDepartmentCard(Employee employee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.apartment_outlined,
            'Department',
            employee.departmentName,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Joined',
            EHelperFunctions.formatDate(employee.createdAt),
          ),
        ],
      ),
    );
  }

  /// Info row widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: EColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: EColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EColors.dark.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: EColors.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Logout button
  Widget _buildLogoutButton(LoginProvider loginProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final shouldLogout = await _showLogoutConfirmationDialog();
          if (shouldLogout && mounted) {
            await loginProvider.logout(context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: EColors.danger,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logout confirmation dialog
  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: EColors.dark,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.lexend(
              fontSize: 15,
              color: EColors.dark.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.lexend(
                  color: EColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Logout',
                style: GoogleFonts.lexend(
                  color: EColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}