import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
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
                      'تعيين كلمة مرور جديدة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل الرمز المرسل إلى ${widget.email} وكلمة المرور الجديدة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // OTP Row
                    const Text(
                      'رمز التحقق',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
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
                    _buildTextField(
                      controller: _newPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_reset,
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'يرجى إدخال كلمة المرور';
                        if (value.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                        return null;
                      },
                      context: context,
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    _buildLabel('تأكيد كلمة المرور'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_reset,
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) return 'يرجى تأكيد كلمة المرور';
                        if (value != _newPasswordController.text) return 'كلمات المرور غير متطابقة';
                        return null;
                      },
                      context: context,
                    ),

                    const SizedBox(height: 32),

                    Consumer<UserViewModel>(
                      builder: (context, userVM, child) => DefaultButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_otpCode.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('يرجى إدخال رمز التحقق كاملاً')),
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
                                SnackBar(
                                  content: const Text('تم تغيير كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن'),
                                  backgroundColor: Theme.of(context).colorScheme.tertiary,
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
      width: 55,
      height: 55,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Theme.of(context).colorScheme.tertiary.withAlpha(10),
          border: OutlineInputBorder(borderRadius: Constants.BORDER_RADIUS_5),
          enabledBorder: OutlineInputBorder(
            borderRadius: Constants.BORDER_RADIUS_5,
            borderSide: const BorderSide(color: Colors.transparent),
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
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF222222)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.tertiary, size: 22),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary.withAlpha(10),
        border: OutlineInputBorder(borderRadius: Constants.BORDER_RADIUS_5),
        enabledBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
