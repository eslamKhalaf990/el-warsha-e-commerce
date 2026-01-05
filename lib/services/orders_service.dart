import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:warsha_commerce/models/create_order_request.dart';
import 'package:warsha_commerce/models/orderModel.dart';
import 'package:warsha_commerce/utils/const_values.dart';

import 'base_url.dart';

class OrdersService {

  Future<http.Response> addOrder(CreateOrderRequest orderRequest, String token) async {
    print("addOrder ${orderRequest.toJson()}");
    final response = await http
        .post(
      Uri.parse(Baseurl.placeOrderAPI),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "Authorization": 'Bearer $token',
      },
      body: jsonEncode(orderRequest.toJson()),
    )
        .timeout(const Duration(seconds: Constants.TIMEOUT));

    if (response.statusCode == 201 || response.statusCode == 200) {

    } else {
      // If the server didn't create the order, throw an error
      throw Exception(
          'Failed to add order: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> applyVoucher(String token, String code, double cartTotal) async {
    final response = await http
        .post(
      Uri.parse(Baseurl.validateVoucher),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "Authorization": 'Bearer $token',
      },
      body: jsonEncode({
        "code": code,
        "cartTotal": cartTotal
      }),
    )
        .timeout(const Duration(seconds: Constants.TIMEOUT));

    if (response.statusCode == 201 || response.statusCode == 200) {

    } else {
      // If the server didn't create the order, throw an error
      throw Exception(
          'Failed to add order: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> getAllOrders(String token) async {
      debugPrint("getAllOrders called");
      http.Response response;
      try {
        response = await http.get(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "Authorization": 'Bearer $token',
          },
          Uri.parse(
            Baseurl.getAllOrderAPI,
          ),
        ).timeout(const Duration(seconds: Constants.TIMEOUT));
      } on TimeoutException {
        throw Exception('The request timed out. Please try again later.');
      } catch (e) {
        throw Exception('Failed to get your orders: $e');
      }
      return response;
    }

  Future<http.Response> cancelOrder(String order, String token) async {
    debugPrint("cancelOrder called $order");
    http.Response response;
    try {
      response = await http.put(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          "Authorization": 'Bearer $token',
        },
        Uri.parse(
          "${Baseurl.cancelOrderAPI}/$order",
        ),
      ).timeout(const Duration(seconds: Constants.TIMEOUT));

    } on TimeoutException {
      throw Exception('The request timed out. Please try again later.');
    } catch (e) {
      throw Exception('Failed to cancel your order: $e');
    }
    return response;
  }
}
