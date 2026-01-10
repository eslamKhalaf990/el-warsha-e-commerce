import 'package:flutter/cupertino.dart';
import 'package:warsha_commerce/services/customers_services.dart';

class CustomerVM extends ChangeNotifier {
  final CustomerService _customerService;

  bool isLoading = false;
  bool isLogin = true;

  CustomerVM(this._customerService);

  Future<String> addCustomer(String name, String governorate, String phone, String address, String secondaryPhone, String city, String email, String password) async {
    String status = "";
    try {
      isLoading = true;
      notifyListeners();
      final response = await _customerService.addCustomer(name, governorate, phone, address,secondaryPhone,city, email, password);
      if (response.statusCode == 201) {
        status = "customer_added";
        debugPrint("customer added successfully");
      } else {
        status = "customer_not_added";
        debugPrint("Failed to add customer: ${response.statusCode}");
      }
    } catch (e) {
      status = "customer_not_added";
      debugPrint("Error fetching customer: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return status;
  }

  void toggleLogin(bool state) {
    isLogin = state;
    notifyListeners();
  }
}
