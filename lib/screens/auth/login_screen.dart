import 'package:emotion_check_in_app/components/buttons/custom_button.dart';
import 'package:emotion_check_in_app/components/formFields/custom_text_form_field.dart';
import 'package:emotion_check_in_app/provider/login_provider.dart';
import 'package:emotion_check_in_app/screens/main/home_screen.dart';
import 'package:emotion_check_in_app/utils/constants/colors.dart';
import 'package:emotion_check_in_app/utils/constants/image_strings.dart';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:emotion_check_in_app/utils/helpers/helper_functions.dart';
import 'package:emotion_check_in_app/utils/validator/validator.dart';
import 'package:flutter/material.dart';
import 'package:emotion_check_in_app/utils/theme/text_theme.dart';
import 'package:emotion_check_in_app/utils/constants/sizes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final loginProvider = context.read<LoginProvider>();

      bool success = await loginProvider.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        debugPrint("Login Successful!");
        EHelperFunctions.navigateToScreen(context, HomeScreen());
      } else {
        debugPrint("Login Failed!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:  Text("Invalid credentials. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final bool isLoading = loginProvider.isLoading;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: ESizes.md),
                width: double.infinity,

                /// Form
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// ATA Logo
                        _logoSection(),
                        const SizedBox(height: 70),

                        /// Form Title
                        _formTitleSection(),
                        const SizedBox(height: 15),

                        /// Email Field
                        CustomTextFormField(
                          controller: _emailController,
                          labelText: ETexts.EMAIL,
                          keyboardType: TextInputType.emailAddress,
                          validator: EValidator.validateEmail,
                        ),
                        const SizedBox(height: 20),

                        /// Password Field with Visibility Toggle
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: ETexts.PASSWORD,
                          obscureText: !_isPasswordVisible,
                          validator: EValidator.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Forgot Password
                        // _forgotPasswordSection(),
                        const SizedBox(height: 10),

                        /// Login Button
                        CustomButton(
                          width: ESizes.wFull,
                          height: ESizes.hNormal,
                          onPressed: isLoading ? null : _handleLogin,
                          child: Text(
                            ETexts.LOGIN,
                            style: ETextTheme.lightTextTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// **Full-Screen Loading Overlay**
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: EColors.primary,
                strokeWidth: 3.0,
              ),
            ),
          ),
      ],
    );
  }

  Align _forgotPasswordSection() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password logic
        },
        child: const Text(
          ETexts.FORGOTPW,
          style: TextStyle(color: EColors.grey),
        ),
      ),
    );
  }

  Text _formTitleSection() {
    return Text(
      ETexts.LOGINPAGETITLE,
      textAlign: TextAlign.start,
      style: ETextTheme.lightTextTheme.titleMedium,
    );
  }

  Image _logoSection() {
    return Image.asset(
      EImages.ataLogo,
      height: ESizes.hNormal,
    );
  }
}