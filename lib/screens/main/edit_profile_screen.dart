import 'dart:io';
import 'package:emc_mob/models/employee_model.dart';
import 'package:emc_mob/providers/employee_provider.dart';
import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/constants/sizes.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Employee employee;

  const EditProfileScreen({super.key, required this.employee});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;

  String? _selectedGender;
  File? _selectedImage;
  DateTime? _selectedDate;

  final List<Map<String, String>> _genderOptions = [
    {'value': 'MALE', 'label': 'Male'},
    {'value': 'FEMALE', 'label': 'Female'},
    {'value': 'PREFER_NOT_TO_SAY', 'label': 'Prefer Not To Say'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final nameParts = widget.employee.fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _phoneController = TextEditingController(
      text: widget.employee.phone?.replaceAll(RegExp(r'\D'), '') ?? '',
    );
    _selectedGender = widget.employee.gender;

    /// Parse birthdate if exists
    if (widget.employee.birthdate != null && widget.employee.birthdate!.isNotEmpty) {
      try {
        /// Try parsing ISO format first
        _selectedDate = DateTime.parse(widget.employee.birthdate!);
        _birthdateController = TextEditingController(
          text: DateFormat('MMMM d, yyyy').format(_selectedDate!),
        );
        debugPrint('Parsed birthdate: $_selectedDate');
      } catch (e) {
        try {
          /// Try parsing with display format
          _selectedDate = DateFormat('MMMM d, yyyy').parse(widget.employee.birthdate!);
          _birthdateController = TextEditingController(text: widget.employee.birthdate!);
          debugPrint('Parsed birthdate from display format: $_selectedDate');
        } catch (e2) {
          debugPrint('Error parsing birthdate: $e2');
          /// If parsing fails, leave empty
          _selectedDate = null;
          _birthdateController = TextEditingController(text: '');
        }
      }
    } else {
      _selectedDate = null;
      _birthdateController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        EHelperFunctions.showSnackBar(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: EColors.primary,
              onPrimary: EColors.white,
              onSurface: EColors.dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      EHelperFunctions.showSnackBar(context, 'Please select gender');
      return;
    }

    if (_selectedDate == null) {
      EHelperFunctions.showSnackBar(context, 'Please select birthdate');
      return;
    }

    debugPrint('Saving profile with birthdate: $_selectedDate');
    debugPrint('Selected image: $_selectedImage');

    final employeeProvider = context.read<EmployeeProvider>();

    final success = await employeeProvider.updateEmployeeData(
      id: widget.employee.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender!,
      birthdate: _selectedDate!,
      avatarFile: _selectedImage,
    );

    if (mounted) {
      if (success) {
        await employeeProvider.fetchEmployeeData();

        if (mounted) {
          EHelperFunctions.showSnackBar(
            context,
            'Profile updated successfully',
          );
          Navigator.pop(context);
        }
      } else {
        EHelperFunctions.showSnackBar(
          context,
          employeeProvider.errorMessage ?? 'Failed to update profile',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: EColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: EColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: EColors.dark,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(ESizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Avatar Section
                  _buildAvatarSection(),
                  const SizedBox(height: 24),

                  /// Name Fields
                  _buildNameFields(),
                  const SizedBox(height: 16),

                  /// Phone Field
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  /// Gender Dropdown
                  _buildGenderDropdown(),
                  const SizedBox(height: 16),

                  /// Birthdate Field
                  _buildBirthdateField(),
                  const SizedBox(height: 32),

                  /// Save Button
                  _buildSaveButton(employeeProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          /// Loading Overlay
          if (employeeProvider.isUpdating)
            Container(
              color: EColors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: EColors.primary,
                  strokeWidth: 3.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: EColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: EColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : widget.employee.avatar != null && widget.employee.avatar!.isNotEmpty
                  ? Image.network(
                widget.employee.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar();
                },
              )
                  : _buildInitialsAvatar(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: EColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: EColors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: EColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar() {
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
          EHelperFunctions.getInitialName(widget.employee.fullName),
          style: GoogleFonts.lexend(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: EColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'Phone Number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }
        if (value.length < 5) {
          return 'Phone number must be at least 5 digits';
        }
        if (value.length > 12) {
          return 'Phone number must not exceed 12 digits';
        }
        if (!RegExp(r'^[\d]+$').hasMatch(value)) {
          return 'Phone number must contain only digits';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wc_outlined,
                  color: EColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Gender',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem<String>(
                value: gender['value'],
                child: Text(
                  gender['label']!,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: EColors.dark,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            hint: Text(
              'Select gender',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: EColors.dark.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdateField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cake_outlined,
                  color: EColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Birthdate',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthdateController,
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(Icons.calendar_today, color: EColors.primary, size: 20),
              hintText: 'Please select date', // Updated placeholder
              hintStyle: GoogleFonts.lexend(
                fontSize: 14,
                color: EColors.dark.withOpacity(0.5),
              ),
            ),
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: EColors.dark,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Birthdate is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: EColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.lexend(
                fontSize: 14,
                color: EColors.dark.withOpacity(0.5),
              ),
            ),
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: EColors.dark,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(EmployeeProvider employeeProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: employeeProvider.isUpdating ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: EColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          employeeProvider.isUpdating ? 'Saving...' : 'Save Changes',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: EColors.white,
          ),
        ),
      ),
    );
  }
}