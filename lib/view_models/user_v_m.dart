import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha_commerce/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
      try {
        final Map<String, dynamic> userMap = jsonDecode(userDataString);
        token = userMap['token'] ?? "-";
        address = userMap['address'] ?? "-";
        name = userMap['name'] ?? "-";
        phone = userMap['phone'] ?? "-";
        email = userMap['email'] ?? "-";
        governorate = userMap['governorate'] ?? "-";

        notifyListeners();
        debugPrint("User state restored from storage");
      } catch (e) {
        debugPrint("Error parsing saved user data: $e");
      }
    }
  }

  // 2. Add Customer (Matches backend logic for registration)
  Future<String> addCustomer(
      String name,
      String governorate,
      String phone,
      String address,
      String secondaryPhone,
      String city,
      String email,
      String password,
      ) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.addCustomer(
        name,
        governorate,
        phone,
        address,
        secondaryPhone,
        city,
        email,
        password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        status = "customer_added";
        notifyListeners();
        debugPrint("Customer added successfully");
      } else if (response.body.contains("Duplicate") || response.statusCode == 409 || response.statusCode == 400) {
        status = "customer_already_exists";
        debugPrint("Customer already exists");
      } else {
        status = "customer_not_added";
        debugPrint("Failed to add customer: ${response.statusCode}");
      }
    } catch (e) {
      status = "customer_not_added";
      debugPrint("Error adding customer: $e");
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 3. Login (Synchronized with AuthController.java customerLogin)
  Future<String> login(String username, String password) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.login(username, password);

      if (response.statusCode == 200) {
        // Active customer logged in successfully
        final data = jsonDecode(response.body);

        // Map keys to match Java record: CustomerLogin(token, address, name, phone, email, governorate)
        token = data["token"] ?? "-";
        address = data["address"] ?? "-";
        name = data["name"] ?? "-";
        phone = data["phone"] ?? "-";
        email = data["email"] ?? "-";
        governorate = data["governorate"] ?? "-";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        status = "logged_in";
        notifyListeners();
        debugPrint("Logged in and data persisted");

      } else if (response.statusCode == 403 && response.body.contains("Account needs verification")) {
        // Pending customer triggers OTP flow (HttpStatus.FORBIDDEN in Java)
        status = "otp_sent";
        debugPrint("Account pending. OTP Sent.");

      } else if (response.statusCode == 401) {
        // BadCredentialsException or "Account is not active"
        status = "invalid_credentials";
        debugPrint("Login failed: Unauthorized");

      } else {
        status = "failed_login";
        debugPrint("Login failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      status = "failed_login";
      debugPrint("Error Logging In: $e");
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 4. Verify OTP (Matches verifyCode endpoint)
  Future<String> verifyOtp(String email, String otp) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.verifyOtp(email, otp);

      if (response.statusCode == 200) {
        // Backend returns "Account verified successfully"
        status = "verified";
        debugPrint("OTP Verified successfully");
      } else {
        // Backend returns 400 Bad Request ("Invalid or expired OTP")
        status = "failed_verification";
        debugPrint("OTP Verification failed: ${response.body}");
      }
    } catch (e) {
      status = "failed_verification";
      debugPrint("Error Verifying OTP: $e");
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 5. Change Password
  Future<String> changePassword(String email, String oldPassword, String newPassword) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.changePassword(email, oldPassword, newPassword);

      if (response.statusCode == 200) {
        status = "password_changed";
        debugPrint("Password changed successfully");
      } else {
        status = "failed_change_password";
        debugPrint("Failed to change password: ${response.body}");
      }
    } catch (e) {
      status = "failed_change_password";
      debugPrint("Error changing password: $e");
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 6. Forgot Password
  Future<String> forgotPassword(String email) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.forgotPassword(email);

      if (response.statusCode == 200) {
        status = "otp_sent";
        debugPrint("Forgot password OTP sent");
      } else {
        status = "failed_forgot_password";
        debugPrint("Failed to send forgot password OTP");
      }
    } catch (e) {
      status = "failed_forgot_password";
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 7. Reset Password
  Future<String> resetPassword(String email, String otp, String newPassword) async {
    String status = "";
    try {
      _setLoading(true);

      final response = await _userService.resetPassword(email, otp, newPassword);

      if (response.statusCode == 200) {
        status = "password_reset";
        debugPrint("Password reset successfully");
      } else {
        status = "failed_reset_password";
        debugPrint("Failed to reset password: ${response.body}");
      }
    } catch (e) {
      status = "failed_reset_password";
    } finally {
      _setLoading(false);
    }
    return status;
  }

  // 8. Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    token = "-";
    address = "-";
    name = "-";
    phone = "-";
    email = "-";
    governorate = "-";

    notifyListeners();
    debugPrint("State cleared");
  }

  // Helper method to handle loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}