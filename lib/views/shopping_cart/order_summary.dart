import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/governerates.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/shopping_cart/container_style.dart';

class OrderSummary extends StatefulWidget {
  const OrderSummary({super.key});

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  // 1. Define these variables inside your State class
  final TextEditingController _couponController = TextEditingController();

  bool _isApplyingCoupon = false;
  // To show loading spinner
  @override
  Widget build(BuildContext context) {
    return StyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص الطلب",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // 2. The Widget Code
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 5, 5, 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withAlpha(
                25,
              ), // Increased alpha slightly for better visibility
              borderRadius: Constants.BORDER_RADIUS_5,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 28,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 10),

                // *** THE INPUT FIELD ***
                Expanded(
                  child: TextFormField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      hintText: "أدخل كود الخصم", // "Enter discount code"
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                // *** THE APPLY BUTTON ***
                InkWell(
                  onTap: _isApplyingCoupon
                      ? null
                      : () async {
                          // 1. Get the code
                          String code = _couponController.text.trim();
                          if (code.isEmpty) return;

                          // 2. Set Loading State
                          setState(() => _isApplyingCoupon = true);

                          // 3. Call your API (Logic placeholder)
                          final state = await Provider.of<CartVM>(context, listen: false)
                              .applyVoucher(code, Provider.of<CartVM>(context, listen: false).totalAmount);
                          if(state =="valid"){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم تفعيل كود الخصم',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior
                                    .floating, // Floats above bottom nav
                                backgroundColor: Colors.black,
                              ),
                            );
                          }
                          // 4. Reset Loading State
                          setState(() => _isApplyingCoupon = false);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: Constants.BORDER_RADIUS_5,
                    ),
                    child: _isApplyingCoupon
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          )
                        : Text(
                            "تطبيق", // "Apply"
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _summaryRow(
            "المجموع الفرعي",
            context,
            "${Provider.of<CartVM>(context).totalAmount} EGP",
          ),
          const SizedBox(height: 15),
          _summaryRow(
            "رسوم التوصيل",
            context,
            Provider.of<CartVM>(context).itemCount == 0
                ? "0.0"
                : Governorates.getDeliveryPrice(
                    Provider.of<UserViewModel>(context).governorate,
                  ).toString(),
          ),
          const SizedBox(height: 30),
          Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الإجمالي",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${Provider.of<CartVM>(context).totalAmount + (Provider.of<CartVM>(context).itemCount == 0 ? 0 : Governorates.getDeliveryPrice(Provider.of<UserViewModel>(context).governorate))} EGP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Consumer<TimelineController>(
            builder: (context, timeline, child) => DefaultButton(
              onTap: () async {
                timeline.changePage(2);
              },
              title: "الذهاب للدفع",
              margin: EdgeInsets.zero,
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
        Text(label, style: TextStyle(fontSize: 16)),
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
