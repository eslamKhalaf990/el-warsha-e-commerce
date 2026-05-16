import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/deafualt_form_field.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/forgot_password.dart';
import 'package:warsha_commerce/views/sign_in/verify_otp.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للمتابعة والاستمتاع بكافة المميزات',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Email Field
          _buildLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _emailController,
            title: 'example@email.com',
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validation: (value) =>
                value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildLabel('كلمة المرور'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _passwordController,
            title: '••••••••',
            icon: Icons.lock_outline,
            isPassword: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validation: (value) =>
                value!.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
          ),

          const SizedBox(height: 8),

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
                style: TextStyle(
                  color: Colors.grey[700], 
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Consumer2<UserViewModel, TimelineController>(
            builder: (context, userVM, timeline, child) => SizedBox(
              width: double.infinity,
              height: 55,
              child: DefaultButton(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    final state = await userVM.login(
                        _emailController.text, _passwordController.text);

                    if (!context.mounted) return;

                    if (state == "logged_in") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل الدخول بنجاح'),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      timeline.nextPage();
                    } else if (state == "otp_sent") {
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
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF495057),
      ),
    );
  }
}

