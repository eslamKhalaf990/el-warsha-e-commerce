import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warsha_commerce/utils/const_values.dart'; // Your constants
import 'package:warsha_commerce/utils/default_button.dart'; // Your button

// --- UPDATED MOCK MODEL ---
class ProductModel {
  final String title;
  final double price;
  final List<String> images;
  final List<Color> availableColors;
  final String colorName; // e.g., "Silver"
  final List<String> sizes; // e.g., ["16mm / us 6", "17mm / us 7"]
  final bool inStock;
  final List<String> badges; // e.g., ["1 Year Color Warranty", "Buy 2 Get 1 Free"]

  ProductModel({
    required this.title,
    required this.price,
    required this.images,
    required this.availableColors,
    required this.colorName,
    required this.sizes,
    required this.inStock,
    required this.badges,
  });
}
// ---------------------------

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;

  // State Management
  final ValueNotifier<int> _selectedColorIndex = ValueNotifier(0);
  final ValueNotifier<int> _selectedSizeIndex = ValueNotifier(0);
  final ValueNotifier<int> _currentImageIndex = ValueNotifier(0);
  final ValueNotifier<int> _quantity = ValueNotifier(1);

  ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1. Image Area with Floating Badges
                _buildImageSection(context),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 30),

                    // 2. Title and Price
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600, // Semi-bold but clean
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${product.price.toStringAsFixed(2)} جنيه ",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 3. Stock Status
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: product.inStock ? Colors.green[700] : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.inStock
                              ? "موجود في المخزون"
                              : "غير موجود في المخزون",
                          style: TextStyle(
                            color: product.inStock ? Colors.green[800] : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // 5. Size Selector (Chips)
                    const Text("الحجم", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildSizeSelector(),

                    const SizedBox(height: 25),

                    // 6. Color Selector
                    Text(
                        "اللون: ${product.colorName}",
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    _buildColorSelector(),

                    const SizedBox(height: 25),

                    // 7. Quantity Selector
                    const Text("الكمية", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildQuantitySelector(),

                    const SizedBox(height: 40),

                    // 8. Add to Cart Button (Full Width Black)
                    ValueListenableBuilder(
                        valueListenable: _quantity,
                        builder: (context, qty, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: DefaultButton(title: "اضف للسلة", onTap: (){}, margin: EdgeInsets.zero),
                          );
                        }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Main Image
        AspectRatio(
          aspectRatio: 1.1, // Slightly square/tall
          child: ValueListenableBuilder<int>(
            valueListenable: _currentImageIndex,
            builder: (context, index, _) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // Light grey bg like screenshot
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: NetworkImage(product.images[index]),
                    fit: BoxFit.cover, // Contain to show full accessory
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedSizeIndex,
      builder: (context, selectedIndex, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(product.sizes.length, (index) {
            final isSelected = selectedIndex == index;
            return InkWell(
              onTap: () => _selectedSizeIndex.value = index,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  product.sizes[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildColorSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedColorIndex,
      builder: (context, selectedIndex, _) {
        return Row(
          children: List.generate(product.availableColors.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => _selectedColorIndex.value = index,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(2), // Space for border
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: product.availableColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300), // Inner subtle border
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey pill background
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Decrease
          IconButton(
            onPressed: () {
              if (_quantity.value > 1) _quantity.value--;
            },
            icon: const Icon(Icons.remove, size: 16),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),

          // Value
          ValueListenableBuilder<int>(
            valueListenable: _quantity,
            builder: (context, qty, _) => Text(
              "$qty",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Increase
          IconButton(
            onPressed: () => _quantity.value++,
            icon: const Icon(Icons.add, size: 16),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}