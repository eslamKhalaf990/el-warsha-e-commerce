import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warsha_commerce/services/base_url.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/image_helper.dart';
import 'package:warsha_commerce/views/shopping_cart/cart_items.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.data,
    required this.increment,
    required this.decrement,
    required this.removeItem,
  });

  final CartItemData data;
  final void Function() increment;
  final void Function() decrement;
  final void Function() removeItem;

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: isSmallScreen ? 100 : 120,
          height: isSmallScreen ? 100 : 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: Constants.BORDER_RADIUS_5,
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: ClipRRect(
            borderRadius: Constants.BORDER_RADIUS_5,
            child: Image.network(
              "${Baseurl.baseURLImages}${ImageHelper.extractFileId(data.image)}",
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SpinKitPulse(color: Color(0xFF222222), size: 30),
                );
              },
              errorBuilder: (context, error, stackTrace) => 
                  const Icon(Iconsax.image_copy, color: Colors.grey),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "المقاس: ${data.size}  •  اللون: ${data.color}",
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: removeItem,
                    icon: const Icon(Iconsax.trash_copy, size: 20, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        _buildQtyBtn(Icons.remove, decrement),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "${data.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildQtyBtn(Icons.add, increment),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (data.discount > 0)
                        Text(
                          "${data.price} EGP",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        "${data.totalPrice} EGP",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16, color: const Color(0xFF222222)),
      ),
    );
  }
}
