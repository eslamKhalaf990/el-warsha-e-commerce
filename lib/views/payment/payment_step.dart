import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/governerates.dart';
import 'package:warsha_commerce/utils/navigator.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/shopping_cart/container_style.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});


  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String selectedPaymentMethod = 'cash';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  // Credit card fields
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  //notes
  final TextEditingController notesController = TextEditingController();

  //down payment
  final TextEditingController downPaymentController = TextEditingController();

  @override
  void dispose() {
    downPaymentController.dispose();
    cardHolderController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
       SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [

                    // Payment Methods Section
                    StyledContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "طريقة الدفع",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Cash on Delivery Option
                          _buildPaymentOption(
                            icon: Iconsax.money,
                            title: "الدفع مقدما",
                            subtitle: " الدفع مقدما عن طريق انستا باي او فودافون كاش",
                            value: 'cash',
                          ),
                          const SizedBox(height: 15),

                          // Down payment
                          TextFormField(
                            // controller: cardNumberController,
                            keyboardType: TextInputType.number,
                            onChanged: (value){
                              setState(() {
                                downPaymentController.text = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.money),
                              border: OutlineInputBorder(
                                borderRadius: Constants.BORDER_RADIUS_5,
                                borderSide: BorderSide(color: Colors.grey.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: Constants.BORDER_RADIUS_5,
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: Constants.BORDER_RADIUS_5,
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              labelText: "اكتب قيمة الدفع المقدم",
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: "مثال: 100",
                              suffix: Text("جنيه"),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty){
                                return "ادخل قيمة صالحة";
                              }
                              else if(double.parse(value) < 50.0){
                                return "اقل قيمة صالحة هي 50 جنيه";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Credit Card Option
                          _buildPaymentOption(
                            icon: Iconsax.card,
                            title: "بطاقة ائتمان",
                            subtitle: "ادفع باستخدام بطاقتك الائتمانية",
                            value: 'card',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Order Summary Section
                    _buildOrderSummary(context, formKey, downPaymentController.text),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          if(selectedPaymentMethod == "card"){
            selectedPaymentMethod = value;
          }
        });
      },
      borderRadius: Constants.BORDER_RADIUS_5,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.tertiary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: Constants.BORDER_RADIUS_5,
          color: isSelected
              ? Theme.of(context).colorScheme.tertiary.withAlpha(10)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.tertiary.withAlpha(30)
                    : Colors.grey.shade100,
                borderRadius: Constants.BORDER_RADIUS_5,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (String? newValue) {
              },
              activeColor: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),

        const Text(
          "معلومات البطاقة",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        // Card Number
        TextField(
          controller: downPaymentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "رقم البطاقة",
            hintText: "1234 5678 9012 3456",
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Card Holder Name
        TextField(
          controller: cardHolderController,
          decoration: InputDecoration(
            labelText: "اسم حامل البطاقة",
            hintText: "الاسم كما هو مكتوب على البطاقة",
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Constants.BORDER_RADIUS_5,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Expiry Date and CVV
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: "تاريخ الانتهاء",
                  hintText: "MM/YY",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "CVV",
                  hintText: "123",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: Constants.BORDER_RADIUS_5,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, GlobalKey<FormState> formKey,
      String downPayment
  ) {
    return StyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص الطلب",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _summaryRow("المجموع الفرعي", context, "${Provider.of<CartVM>(context).totalAmount} EGP"),
          const SizedBox(height: 15),
          _summaryRow("مدفوع مقدما", context, "${downPayment == "" ? 0 : downPayment} EGP"),
          const SizedBox(height: 15),
          _summaryRow("رسوم التوصيل", context,
              Provider.of<CartVM>(context).itemCount == 0 ? "0.0 EGP":"${
              Governorates.getDeliveryPrice(Provider.of<UserViewModel>(context)
              .governorate).toString()} EGP"),
          const SizedBox(height: 30),
          Divider(),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              const Text(
                "الإجمالي",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${Provider.of<CartVM>(context).totalAmount - double.parse(downPayment.isEmpty? "0.0" :downPayment) +
                    (Provider.of<CartVM>(context).itemCount == 0 ?
                    0 :
                    Governorates.getDeliveryPrice(Provider.of<UserViewModel>(context).governorate))} EGP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // notes
          TextFormField(
            maxLines: 5,
            onChanged: (value){
              setState(() {
                notesController.text = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.document_text_copy),
              border: OutlineInputBorder(
                borderRadius: Constants.BORDER_RADIUS_5,
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Constants.BORDER_RADIUS_5,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: Constants.BORDER_RADIUS_5,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              labelText: "ملاحظات اضافية: حفر كلمة",
              labelStyle: TextStyle(color: Colors.grey),
              hintText: "مثال: حفر كلمة",
              suffix: Text("جنيه"),
            ),
            validator: (value) {
              return null;
            },
          ),

          const SizedBox(height: 30),

          Consumer<TimelineController>(
            builder: (context, timeline, child) => DefaultButton(
              onTap: () async {
                if(!formKey.currentState!.validate() || downPayment.isEmpty){
                  return;
                }
                final state = await Provider.of<CartVM>(
                  context,
                  listen: false,
                ).placeOrder(downPayment: downPayment.toString(), notes: notesController.text);

                if (state != null) {
                  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedPaymentMethod == 'cash'
                            ? "تم تأكيد طلبك - الدفع عند الاستلام"
                            : "تم تأكيد طلبك والدفع بنجاح",
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                  timeline.changePage(3);
                  Provider.of<CartVM>(
                    context,
                    listen: false,
                  ).clear();
                }
              },
              title: "تأكيد الطلب",
              margin: EdgeInsets.zero,
              isLoading: Provider.of<CartVM>(context).isLoading,
              isValid: !Provider.of<CartVM>(context).isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      BuildContext context,
      String value, {
        bool isRed = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isRed ? Colors.red : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}