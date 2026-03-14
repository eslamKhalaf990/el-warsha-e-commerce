import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/reset_password.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(25),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل بريدك الإلكتروني لتلقي رمز التحقق وتعيين كلمة مرور جديدة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

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

                    const SizedBox(height: 32),

                    Consumer<UserViewModel>(
                      builder: (context, userVM, child) => DefaultButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final state = await userVM.forgotPassword(_emailController.text);

                            if (!context.mounted) return;

                            if (state == "otp_sent") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
                                  backgroundColor: Theme.of(context).colorScheme.tertiary,
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
