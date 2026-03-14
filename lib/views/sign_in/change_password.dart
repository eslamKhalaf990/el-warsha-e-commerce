import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تحديث كلمة المرور',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى إدخال كلمة المرور الحالية والجديدة لتحديث بياناتك',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Current Password Field
                _buildLabel('كلمة المرور الحالية'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _currentPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال كلمة المرور الحالية' : null,
                  context: context,
                ),
                const SizedBox(height: 20),

                // New Password Field
                _buildLabel('كلمة المرور الجديدة'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _newPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'يرجى إدخال كلمة المرور الجديدة';
                    if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                  context: context,
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildLabel('تأكيد كلمة المرور الجديدة'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'يرجى تأكيد كلمة المرور الجديدة';
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
                        final state = await userVM.changePassword(
                          userVM.email,
                          _currentPasswordController.text,
                          _newPasswordController.text,
                        );

                        if (!context.mounted) return;

                        if (state == "password_changed") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('تم تغيير كلمة المرور بنجاح'),
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('فشل تغيير كلمة المرور، يرجى التأكد من كلمة المرور الحالية'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    title: 'تحديث كلمة المرور',
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
