import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:warsha_commerce/models/create_order_request.dart';
import 'package:warsha_commerce/models/orderModel.dart';
import 'package:warsha_commerce/utils/const_values.dart';

import 'base_url.dart';

class OrdersService {

  Future<http.Response> addOrder(
      CreateOrderRequest orderRequest,
      String token, {
        List<Uint8List>? images, // <--- CHANGED: Accepts memory bytes now
      }) async {
    var uri = Uri.parse(Baseurl.placeOrderAPI);

    // 1. Use MultipartRequest
    var request = http.MultipartRequest('POST', uri);

    // 2. Add Headers
    request.headers.addAll({
      "Authorization": 'Bearer $token',
    });

    // 3. Add the JSON Data ("order")
    request.files.add(http.MultipartFile.fromString(
      'order',
      jsonEncode(orderRequest.toJson()),
      contentType: MediaType('application', 'json'),
    ));

    // 4. Add Images ("images") - Fixed for Uint8List
    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {

        // We use fromBytes because we have the data in memory
        var multipartFile = http.MultipartFile.fromBytes(
          'images', // Field name expected by Spring Boot
          images[i],
          // Filename is REQUIRED for the server to treat this as a file
          filename: 'upload_$i.jpg',
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }
    }

    // 5. Send and Parse Response
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            response.body);
      }
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
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
