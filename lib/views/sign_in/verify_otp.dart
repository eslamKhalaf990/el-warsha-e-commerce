import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/view_models/customers_v_m.dart';

class VerifyOtp extends StatefulWidget {
  final String email;

  const VerifyOtp({super.key, required this.email});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Constants.BORDER_RADIUS_5,
              ),
              padding: EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تحقق من الرمز',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل الرمز المكون من 6 أرقام المرسل إلى\n${widget.email}',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600], height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    // 6-Digit OTP Input Row
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        List.generate(6, (index) => _buildOtpBox(index, context)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend OTP
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Implement Resend OTP logic here
                        },
                        child: Text(
                          'لم تستلم الرمز؟ إعادة إرسال',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary.withAlpha(100),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    Consumer2<UserViewModel, TimelineController>(
                      builder: (context, userVM, timeline, child) => DefaultButton(
                        onTap: () async {
                          if (_otpCode.length == 6) {

                            // 1. Call the actual API using the ViewModel
                            final state = await userVM.verifyOtp(widget.email, _otpCode);

                            if (!context.mounted) return;

                            if (state == "verified") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم التحقق بنجاح، يمكنك الآن تسجيل الدخول'),
                                  backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              // Switch main auth view to Login and pop OTP screen
                              Provider.of<CustomerVM>(context, listen: false)
                                  .toggleLogin(true);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرمز غير صحيح أو منتهي الصلاحية، حاول مرة أخرى'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال الرمز كاملاً'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        title: 'تأكيد',
                        margin: EdgeInsets.zero,
                        isValid: !userVM.isLoading && _otpCode.length == 6,
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

  Widget _buildOtpBox(int index, BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Theme.of(context).colorScheme.tertiary.withAlpha(10),
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
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
          setState(() {});
        },
      ),
    );
  }
}