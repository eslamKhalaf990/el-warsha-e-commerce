import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/governerates.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class OrderSummary extends StatefulWidget {
  const OrderSummary({super.key});

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartVM>(context);
    final userVM = Provider.of<UserViewModel>(context);
    final deliveryPrice = cart.itemCount == 0 ? 0.0 : Governorates.getDeliveryPrice(userVM.governorate);
    final totalAmount = cart.totalAmount + deliveryPrice;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Constants.BORDER_RADIUS_5,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص الطلب",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
          ),
          const SizedBox(height: 24),

          // Coupon Section
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: Constants.BORDER_RADIUS_5,
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.confirmation_number_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      hintText: "كود الخصم",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: Constants.BORDER_RADIUS_5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("تطبيق", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          _summaryRow("المجموع الفرعي", "${cart.totalAmount} EGP"),
          const SizedBox(height: 16),
          _summaryRow("رسوم التوصيل", "$deliveryPrice EGP", isValueBold: false),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 1, color: Color(0xFFF1F3F5)),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("الإجمالي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("$totalAmount EGP", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          
          const SizedBox(height: 32),

          Consumer<TimelineController>(
            builder: (context, timeline, child) => Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: DefaultButton(
                    onTap: () => timeline.changePage(2),
                    title: "إتمام الشراء",
                    margin: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => timeline.previousPage(),
                  child: const Text(
                    "العودة للخطوة السابقة",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon() async {
    String code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingCoupon = true);
    
    final cartVM = Provider.of<CartVM>(context, listen: false);
    final state = await cartVM.applyVoucher(code, cartVM.totalAmount);
    
    if (state == "valid") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل كود الخصم بنجاح'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    setState(() => _isApplyingCoupon = false);
  }

  Widget _summaryRow(String label, String value, {bool isValueBold = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: const Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}
