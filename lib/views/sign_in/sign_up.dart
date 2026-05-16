import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/governerates.dart';
import 'package:warsha_commerce/utils/deafualt_form_field.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/sign_in/verify_otp.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _secondPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'انضم إلينا اليوم واستمتع بتجربة تسوق فريدة',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Full Name
          _buildLabel('الاسم بالكامل'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _nameController,
            title: 'مثال: أحمد محمد',
            icon: Iconsax.profile_circle_copy,
            validation: (value) => value!.isEmpty ? 'يرجى إدخال الاسم' : null,
          ),
          const SizedBox(height: 20),

          // Email
          _buildLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _emailController,
            title: 'example@email.com',
            icon: Iconsax.sms_copy,
            inputType: TextInputType.emailAddress,
            validation: (value) =>
                value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
          ),
          const SizedBox(height: 20),

          // Phone Number
          _buildLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _phoneController,
            title: '01xxxxxxxxx',
            icon: Iconsax.call_copy,
            inputType: TextInputType.phone,
            validation: (value) =>
                value!.length < 11 ? 'يرجى إدخال رقم هاتف صحيح' : null,
          ),
          const SizedBox(height: 20),

          // Password
          _buildLabel('كلمة المرور'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _passwordController,
            title: '••••••••',
            icon: Iconsax.key_copy,
            isPassword: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validation: (value) => value!.length < 6
                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                : null,
          ),
          const SizedBox(height: 20),

          // City
          _buildLabel('المحافظة'),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _cityController.text,
            items: Governorates.shippingRates.keys.toList(),
            hint: 'اختر المحافظة',
            icon: Iconsax.location_copy,
            onChanged: (newValue) => setState(() => _cityController.text = newValue!),
            validator: (value) => (value == null || value.isEmpty) ? 'يرجى اختيار المحافظة' : null,
          ),
          const SizedBox(height: 20),

          // Address
          _buildLabel('العنوان بالتفصيل'),
          const SizedBox(height: 8),
          DefaultForm(
            controller: _addressController,
            title: 'اسم الشارع، رقم المبنى، الدور...',
            icon: Iconsax.home_copy,
            numberOfLines: 2,
            validation: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
          ),

          const SizedBox(height: 32),

          Consumer<UserViewModel>(
            builder: (context, userVM, child) => SizedBox(
              width: double.infinity,
              height: 55,
              child: DefaultButton(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    final state = await userVM.addCustomer(
                      _nameController.text,
                      _cityController.text,
                      _phoneController.text,
                      _addressController.text,
                      _secondPhoneController.text,
                      _cityController.text,
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (!context.mounted) return;

                    if (state == "customer_added") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إنشاء الحساب بنجاح'),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyOtp(email: _emailController.text),
                        ),
                      );
                    } else if (state == "customer_already_exists") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("الحساب موجود بالفعل"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("لم يتم إنشاء الحساب"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                title: 'إنشاء حساب جديد',
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

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) && value.isNotEmpty ? value : null,
      items: items.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF222222), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: Constants.BORDER_RADIUS_5,
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: Constants.BORDER_RADIUS_5,
    );
  }
}
