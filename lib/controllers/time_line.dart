import 'package:flutter/material.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'package:warsha_commerce/views/orders/order_completed.dart';
import 'package:warsha_commerce/views/payment/payment_step.dart';
import 'package:warsha_commerce/views/shopping_cart/cart_items.dart';
import 'package:warsha_commerce/views/shopping_cart/order_summary.dart';
import 'package:warsha_commerce/views/sign_in/sign_in.dart';

class TimelineController extends ChangeNotifier {
  int page = 0;
  bool _initialized = false;

  void checkAuth(UserViewModel userVM) {
    if (!_initialized) {
      if (userVM.token != "-") {
        page = 1; // Skip Sign In if token is present
      } else {
        page = 0;
      }
      _initialized = true;
      // No notifyListeners() here to avoid build errors during init, 
      // though Provider takes care of it usually if called from build.
    }
  }

  // Allow resetting initialization if needed (e.g. after logout)
  void reset() {
    _initialized = false;
  }

  final List<Widget> desktopSteps = [
    DeliveryDetailsPage(),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 10,
            child: RightCartColumn()
        ),
        const SizedBox(width: 40),
        const Expanded(
            flex: 6,
            child: OrderSummary()
        ),
      ],
    ),
    Payment(),
    OrderCompleted(orderNumber: '', totalAmount: '',),
  ];

  final List<Widget> mobileSteps = [
    DeliveryDetailsPage(),
    Column(
      children: [
        RightCartColumn(),
        const SizedBox(height: 40),
        const OrderSummary(),
      ],
    ),
    Payment(),
    OrderCompleted(orderNumber: '', totalAmount: '',),

  ];

  void nextPage() {
    if (page < desktopSteps.length - 1) {
      page++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (page > 0) {
      page--;
      notifyListeners();
    }
  }

  void changePage(int index) {
    page = index;
    notifyListeners();
  }
}
