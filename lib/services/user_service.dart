import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:warsha_commerce/utils/const_values.dart';
import 'base_url.dart';

class UserService {
  Future<http.Response> login (String username, String password) async {
    debugPrint("login using $username account");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.loginApi,
          ),
          body: jsonEncode({
            "username": username,
            "password": password,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to login with these credentials: $e');
    }
    return response;
  }

  Future<http.Response> verifyOtp (String email, String otp) async {
    debugPrint("verify for $email account");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.verifyOtp,
          ),
          body: jsonEncode({
            "email": email,
            "otp": otp,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to login with these credentials: $e');
    }
    return response;
  }

  Future<http.Response> addCustomer(String name, String governorate, String phone, String address, String secondaryPhone, String city, String email, String password) async {
    debugPrint("addCustomer called $name");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.signUpCustomerAPI,
          ),
          body: jsonEncode({
            "fullName": name,
            "phone": phone,
            "email": email,
            "password": password,
            "governorate": governorate,
            "address": address,
            "secondaryPhone": secondaryPhone,
            "city": city,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to add your new customer: $e');
    }
    return response;
  }

  Future<http.Response> changePassword(String email, String oldPassword, String newPassword) async {
    debugPrint("changePassword for $email account");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.changePasswordApi,
          ),
          body: jsonEncode({
            "email": email,
            "oldPassword": oldPassword,
            "newPassword": newPassword,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
    return response;
  }

  Future<http.Response> forgotPassword(String email) async {
    debugPrint("forgotPassword for $email account");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.forgotPasswordApi,
          ),
          body: jsonEncode({
            "email": email,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));
      print(response.body);
      print(response.statusCode);
    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to send forgot password request: $e');
    }
    return response;
  }

  Future<http.Response> resetPassword(String email, String otp, String newPassword) async {
    debugPrint("resetPassword for $email account");
    http.Response response;
    try {
      response = await http.post(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          Uri.parse(
            Baseurl.resetPasswordApi,
          ),
          body: jsonEncode({
            "email": email,
            "otp": otp,
            "newPassword": newPassword,
          })
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
    return response;
  }

}