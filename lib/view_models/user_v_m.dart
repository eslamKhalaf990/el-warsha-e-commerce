import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha_commerce/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  bool isLoading = false;
  final UserService _userService;

  // State variables
  String token = "-";
  String address = "-";
  String name = "-";
  String phone = "-";
  String email = "-";
  String governorate = "-";

  UserViewModel(this._userService) {
    loadSavedUser();
  }

  // 1. Restore state from LocalStorage
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final Map<String, dynamic> userMap = jsonDecode(userDataString);
      token = userMap['token'] ?? "-";
      address = userMap['address'] ?? "-";
      name = userMap['name'] ?? "-";
      phone = userMap['phone'] ?? "-";
      email = userMap['email'] ?? "-";
      governorate = userMap['governorate'] ?? "-";

      notifyListeners();
      debugPrint("User state restored from storage");
    }
  }

  Future<String> addCustomer(String name, String governorate, String phone, String address, String secondaryPhone, String city, String email, String password) async {
    String status = "";
    try {
      isLoading = true;
      notifyListeners();
      final response = await _userService.addCustomer(name, governorate, phone, address, secondaryPhone, city, email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update local variables
        token = data["token"];
        address = data["address"];
        name = data["name"];
        phone = data["phone"];
        email = data["email"];
        governorate = data["governorate"];

        // 2. Persist entire object as a JSON string
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

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


  Future<String> login(String username, String password) async {
    String status = "";
    try {
      isLoading = true;
      notifyListeners();

      final response = await _userService.login(username, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update local variables
        token = data["token"];
        address = data["address"];
        name = data["name"];
        phone = data["phone"];
        email = data["email"];
        governorate = data["governorate"];

        // 2. Persist entire object as a JSON string
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        status = "logged_in";
        debugPrint("Logged in and data persisted");
      } else {
        status = "failed_login";
      }
    } catch (e) {
      status = "failed_login";
      debugPrint("Error Logging In: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return status;
  }

  // 3. Clear storage on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    // Reset variables
    token = "-";
    address = "-";
    name = "-";
    phone = "-";
    email = "-";
    governorate = "-";

    notifyListeners();
    debugPrint("State cleared");
  }
}