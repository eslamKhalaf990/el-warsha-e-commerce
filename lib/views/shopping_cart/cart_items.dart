import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';
import 'cart_item.dart';
import 'container_style.dart';

class CartItemData {
  final String name;
  final String image;
  final String size;
  final String category;
  final String color;
  final double price;
  final double totalPrice;
  final double discount;
  final int quantity;

  const CartItemData({
    required this.name,
    required this.image,
    required this.size,
    required this.category,
    required this.color,
    required this.price,
    required this.totalPrice,
    required this.discount,
    required this.quantity,
  });
}

class RightCartColumn extends StatelessWidget {
  const RightCartColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartVM>(context);
    final cartItems = cart.items.values.toList();
    final productIds = cart.items.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
            child: Row(
              children: [
                const Icon(Icons.shopping_basket_outlined, size: 20),
                const SizedBox(width: 12),
                Text(
                  "سلة التسوق (${cart.itemCount} منتجات)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => cart.clear(),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text("حذف السلة", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        cartItems.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) {
                  final providerItem = cartItems[i];
                  final currentId = productIds[i];

                  final uiModel = CartItemData(
                    name: providerItem.title,
                    category: providerItem.category,
                    color: "أسود",
                    price: providerItem.price,
                    quantity: providerItem.quantity,
                    totalPrice: providerItem.totalPrice,
                    discount: providerItem.discount,
                    image: providerItem.imageUrl,
                    size: 'M',
                  );

                  return Container(
                    padding: const EdgeInsets.all(16),
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
                    child: CartItemRow(
                      data: uiModel,
                      increment: () => cart.incrementItemQty(currentId),
                      decrement: () => cart.decrementItemQty(currentId),
                      removeItem: () => cart.removeItem(currentId),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Constants.BORDER_RADIUS_5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            "سلة التسوق فارغة",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: Constants.BORDER_RADIUS_5),
            ),
            child: const Text("ابدأ التسوق الآن", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
