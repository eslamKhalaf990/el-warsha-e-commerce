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
    // Check if screen is very small to adjust layout inside row
    bool isSmallScreen = MediaQuery.of(context).size.width < 500;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Placeholder
        Container(
          width: isSmallScreen ? 80 : 110, // Smaller image on mobile
          height: isSmallScreen ? 80 : 110,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withAlpha(10),
            borderRadius: Constants.BORDER_RADIUS_5,
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.tertiary.withAlpha(20),
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceTint,
              borderRadius: Constants.BORDER_RADIUS_20,
            ),
            child: ClipRRect(
              borderRadius: Constants.BORDER_RADIUS_5,
              child: Image.network(
                "${Baseurl.baseURLImages}${ImageHelper.extractFileId(data.image)}",
                width: isSmallScreen ? 70 : 100, // Smaller image on mobile
                height: isSmallScreen ? 70 : 100,
                fit: BoxFit.cover,
                // Show a loading spinner while the image is loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: SpinKitChasingDots(
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                  );
                },
                // Show a fallback if the image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Iconsax.shopping_bag, size: 40);
                },
              ),
            ),
          ),
        ),

        SizedBox(width: isSmallScreen ? 15 : 25),

        // Item Details (Wrapped in Expanded to avoid overflow)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment
                .center, // Centers content vertically if image is tall
            children: [
              // 1. Name: Limit lines to prevent it from eating all vertical space
              Text(
                data.name,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? 14
                      : 18, // Slightly smaller base for mobile
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Text(
                "النوع: ${data.category}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              // Spacer pushes pricing to the bottom, or just use SizedBox for fixed gap
              const SizedBox(height: 8),

              if (data.discount > 0) ...[
                // 2. Responsive Price Layout using WRAP
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8, // Horizontal space between items
                  runSpacing: 4, // Vertical space if it wraps to next line
                  children: [
                    // A. Final Price (The Hero)
                    Column(
                      children: [
                        Text(
                          "${data.totalPrice} EGP",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),

                        // B. Old Price (Struck through)
                        Text(
                          "${data.price} EGP",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),

                    // C. The Savings Badge (Optional: Keep it inside Wrap or move above)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        "SAVE ${data.discount}", // Short text for mobile
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  "${data.totalPrice} EGP",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Actions (Trash & Counter)
        SizedBox(
          height: isSmallScreen ? 80 : 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: removeItem,
                icon: Icon(Iconsax.trash_copy, color: Colors.red),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 4 : 8,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withAlpha(10),
                  borderRadius: Constants.BORDER_RADIUS_5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: increment,
                      icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
                    ),
                    SizedBox(width: isSmallScreen ? 5 : 5),
                    Text(
                      "${data.quantity}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 5),
                    IconButton(
                      onPressed: decrement,
                      icon: Icon(Icons.remove, size: isSmallScreen ? 16 : 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
