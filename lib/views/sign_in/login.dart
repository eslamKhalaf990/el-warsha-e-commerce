import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/forgot_password.dart';
import 'package:warsha_commerce/views/sign_in/verify_otp.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مرحباً بعودتك',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للمتابعة',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Email Field
          _buildLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'example@email.com',
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validator: (value) =>
            value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
            context: context,
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildLabel('كلمة المرور'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) =>
            value!.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
            context: context,
          ),

          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Consumer2<UserViewModel, TimelineController>(
            builder: (context, userVM, timeline, child) => DefaultButton(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  final state = await userVM.login(
                      _emailController.text, _passwordController.text);

                  if (!context.mounted) return;

                  if (state == "logged_in") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم تسجيل الدخول بنجاح'),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    Navigator.pop(context); // Exit auth flow
                  } else if(state == "otp_sent"){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VerifyOtp(email: _emailController.text),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('فشل تسجيل الدخول، تأكد من البيانات'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              title: 'تسجيل الدخول',
              margin: EdgeInsets.zero,
              isValid: !userVM.isLoading,
              isLoading: userVM.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF222222),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.tertiary,
          size: 22,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary.withAlpha(10),
        contentPadding: EdgeInsets.symmetric(
          vertical: maxLines > 1 ? 16 : 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary.withAlpha(0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
