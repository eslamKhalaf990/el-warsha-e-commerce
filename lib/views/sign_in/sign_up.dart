import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/governerates.dart';
import 'package:warsha_commerce/utils/navigator.dart';
import 'package:warsha_commerce/view_models/customers_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm({super.key});

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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'املأ البيانات التالية لإنشاء حسابك',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Full Name
          _buildLabel('الاسم بالكامل'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'مثال: أحمد محمد',
            icon: Iconsax.profile_circle_copy,
            validator: (value) => value!.isEmpty ? 'يرجى إدخال الاسم' : null,
            context: context,
          ),
          const SizedBox(height: 20),

          // Email
          _buildLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'example@email.com',
            icon: Iconsax.sms_copy,
            inputType: TextInputType.emailAddress,
            validator: (value) =>
            value!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
            context: context,
          ),
          const SizedBox(height: 20),

          // Phone Number
          _buildLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _phoneController,
            hint: '01xxxxxxxxx',
            icon: Iconsax.call_copy,
            inputType: TextInputType.phone,
            validator: (value) =>
            value!.length < 11 ? 'يرجى إدخال رقم هاتف صحيح' : null,
            context: context,
          ),
          const SizedBox(height: 20),

          // Additional Phone Number
          _buildLabel('رقم هاتف اضافي (اختياري)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _secondPhoneController,
            hint: '01xxxxxxxxx',
            icon: Iconsax.call_copy,
            inputType: TextInputType.phone,
            context: context,
          ),
          const SizedBox(height: 20),

          // Password
          _buildLabel('كلمة المرور'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Iconsax.key_copy,
            isPassword: true,
            validator: (value) => value!.length < 6
                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                : null,
            context: context,
          ),
          const SizedBox(height: 20),

          // City
          _buildLabel('المحافظة / المدينة'),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _cityController.text ?? '',
            items: Governorates.shippingRates.keys.toList(),
            hint: 'اختر المدينة',
            icon: Iconsax.location_copy,
            context: context,
            onChanged: (newValue) {
              setState(() {
                _cityController.text = newValue!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى اختيار المدينة';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Address
          _buildLabel('العنوان بالتفصيل'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _addressController,
            hint: 'اسم الشارع، رقم المبنى، الدور...',
            icon: Iconsax.home_copy,
            maxLines: 3,
            validator: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
            context: context,
          ),

          const SizedBox(height: 32),

          Consumer<UserViewModel>(
            builder: (context, userVM, child) => // Inside SignUpForm -> build -> Column -> Consumer<CustomerVM> -> DefaultButton
            DefaultButton(
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

                  if (state == "customer_added") {
                    // Success Feedback
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                      SnackBar(
                        content: Text('تم إنشاء الحساب بنجاح، يمكنك متابعة طلبك'), // Account created
                        backgroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.tertiary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Provider.of<TimelineController>(navigatorKey.currentContext!, listen: false).changePage(1);

                    // Switch to login tab
                    // userVM.toggleLogin(true);
                  } else {
                    // Optional: Error Feedback
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                      SnackBar(
                        content: Text("لم يتم إنشاء الحساب"), // Error message
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              title: 'إنشاء الحساب',
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

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    required BuildContext context,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) && value.isNotEmpty ? value : null,
      items: items.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.tertiary),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        // Set Border Radius to 25 as requested
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary.withAlpha(0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      // Ensures the dropdown menu itself follows the rounded theme
      dropdownColor: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(25),
    );
  }
}
