import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/deafualt_form_field.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

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
                      'تعيين كلمة مرور جديدة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل الرمز المرسل إلى ${widget.email} وكلمة المرور الجديدة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // OTP Row
                    _buildLabel('رمز التحقق'),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // New Password
                    _buildLabel('كلمة المرور الجديدة'),
                    const SizedBox(height: 8),
                    DefaultForm(
                      controller: _newPasswordController,
                      title: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: _obscurePassword,
                      validation: (value) {
                        if (value!.isEmpty) return 'يرجى إدخال كلمة المرور';
                        if (value.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    _buildLabel('تأكيد كلمة المرور'),
                    const SizedBox(height: 8),
                    DefaultForm(
                      controller: _confirmPasswordController,
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
                      validation: (value) {
                        if (value!.isEmpty) return 'يرجى تأكيد كلمة المرور';
                        if (value != _newPasswordController.text) return 'كلمات المرور غير متطابقة';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    Consumer<UserViewModel>(
                      builder: (context, userVM, child) => DefaultButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_otpCode.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى إدخال رمز التحقق كاملاً'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final state = await userVM.resetPassword(
                              widget.email,
                              _otpCode,
                              _newPasswordController.text,
                            );

                            if (!context.mounted) return;

                            if (state == "password_reset") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن'),
                                  backgroundColor: Colors.black,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              // Go back to login
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرمز غير صحيح أو فشل تعيين كلمة المرور'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        title: 'تأكيد',
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

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: Constants.BORDER_RADIUS_5,
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: Constants.BORDER_RADIUS_5,
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: Constants.BORDER_RADIUS_5,
            borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
          }
        },
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
