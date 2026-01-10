import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:warsha_commerce/models/cart.dart';
import 'package:warsha_commerce/models/create_order_request.dart';
import 'package:warsha_commerce/models/orderItemModel.dart';
import 'package:warsha_commerce/models/orderModel.dart';
import 'package:warsha_commerce/models/order_response.dart';
import 'package:warsha_commerce/models/product_model.dart';
import 'package:warsha_commerce/services/base_url.dart';
import 'package:warsha_commerce/services/orders_service.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class CartVM with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  OrderResponse? orderResponse;
  final OrdersService _ordersService;
  final UserViewModel _userViewModel;
  bool _isLoading = false;
  String coupon = "";

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  CartVM(this._ordersService, this._userViewModel);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<String?> applyVoucher(String code, double cartTotal) async {

    // 1. Set Loading
    _isLoading = true;
    notifyListeners();

    try {
      // 4. Send Request (toJson handles the formatting now)
      final response = await _ordersService.applyVoucher(_userViewModel.token, code, cartTotal);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        coupon = code;

        return "valid";
      } else {
        coupon = "";
        print("Failed: ${response.statusCode} | ${response.body}");
        return null;
      }
    } catch (error) {

      _isLoading = false;
      notifyListeners();
      return null;
    } finally {

      _isLoading = false;
      notifyListeners();
    }
  }


  Future<OrderResponse?> placeOrder({
    double discount = 0.0,
    String paymentMethod = "Cash",
    String orderSource = "E-Commerce",
    required String downPayment,
    String bankAccountId = "8",
    String notes = "",
    List<Uint8List>? images
  }) async {

    // 1. Set Loading
    _isLoading = true;
    notifyListeners();

    // 2. Convert Cart Items -> CreateOrderItem (The API Model)
    List<CreateOrderItem> cartItems = _items.values.map((cartItem) {
      return CreateOrderItem(
        productId: cartItem.id,
        quantity: cartItem.quantity,
        unitPrice: cartItem.price,
      );
    }).toList();

    if(Baseurl.baseURL == "http://localhost:8080/"){bankAccountId = "5";}

    // 3. Create the Main Request Object
    CreateOrderRequest requestModel = CreateOrderRequest(
      discount: discount,
      downPayment: downPayment,
      bankAccountId: bankAccountId,
      notes: notes,
      orderSource: orderSource,
      paymentMethod: paymentMethod,
      items: cartItems,
    );

    try {


      // 4. Send Request (toJson handles the formatting now)
      final response = await _ordersService.addOrder(requestModel, _userViewModel.token, images: images);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        orderResponse = OrderResponse.fromJson(responseData);
        return orderResponse;
      } else {
        print("Failed: ${response.statusCode} | ${response.body}");
        return null;
      }
    } catch (error) {
      print("Network Error: $error");
      _isLoading = false;
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Add to Cart
  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      // Update existing
      _items.update(
        product.id,
            (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // Add new
      _items.putIfAbsent(
        product.id,
            () => CartItem(
          id: product.id,
          title: product.name, // Mapped from Product.name
          price: product.sellingPrice, // Mapped from Product.sellingPrice
          imageUrl: product.imageUrl,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // 2. Remove Single Item (Decrement)
  void decrementItemQty(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
            (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // 2. Remove Single Item (Decrement)
  void incrementItemQty(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity < 10) {
      _items.update(
        productId,
            (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + 1,
        ),
      );
    }
    notifyListeners();
  }

  // 3. Remove entirely
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // 4. Clear Cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // 5. NEW: Prepare Data for Checkout API
  // This converts your UI Cart into the OrderModel you showed me
  OrderModel createOrder({String? customerId}) {
    List<OrderItemModel> orderItems = _items.values.map((cartItem) {
      // Assuming OrderItemModel has a structure like this based on your models
      return OrderItemModel(
        productId: cartItem.id,
        quantity: cartItem.quantity,
        productName: cartItem.title,
        unitPrice: cartItem.price,
        // Add other required fields from your OrderItemModel here
      );
    }).toList();

    return OrderModel(
      customerId: customerId,
      orderItems: orderItems,
      totalPrice: totalAmount,
      orderDate: DateTime.now(),
      status: "Pending", // Default status
    );
  }
}