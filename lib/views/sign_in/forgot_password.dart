import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/deafualt_form_field.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/reset_password.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Constants.BORDER_RADIUS_5,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل بريدك الإلكتروني لتلقي رمز التحقق وتعيين كلمة مرور جديدة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
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

                    const SizedBox(height: 32),

                    Consumer<UserViewModel>(
                      builder: (context, userVM, child) => DefaultButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final state = await userVM.forgotPassword(_emailController.text);

                            if (!context.mounted) return;

                            if (state == "otp_sent") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
                                  backgroundColor: Colors.black,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordPage(email: _emailController.text),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('فشل إرسال الرمز، يرجى التأكد من البريد الإلكتروني'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        title: 'إرسال الرمز',
                        margin: EdgeInsets.zero,
                        isValid: !userVM.isLoading,
                        isLoading: userVM.isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
