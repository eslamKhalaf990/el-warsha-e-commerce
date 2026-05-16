import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warsha_commerce/utils/const_values.dart'; // Your constants
import 'package:warsha_commerce/utils/default_button.dart';
import 'package:warsha_commerce/utils/default_footer.dart'; // Your button

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF222222),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.heart_copy, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.share_copy, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return _buildDesktopLayout(context, constraints);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.1,
        vertical: 40,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image Gallery
              Expanded(
                flex: 1,
                child: _buildImageSection(context, isDesktop: true),
              ),
              const SizedBox(width: 60),
              // Right: Product Details
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildProductInfoSection(context),
                    const DefaultFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context, isDesktop: false),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildProductInfoSection(context),
          ),
          const DefaultFooter(),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, {required bool isDesktop}) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: isDesktop ? 1.0 : 1.1,
          child: ValueListenableBuilder<int>(
            valueListenable: _currentImageIndex,
            builder: (context, index, _) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(isDesktop ? 30 : 0),
                  image: DecorationImage(
                    image: NetworkImage(product.images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        if (product.images.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ValueListenableBuilder<int>(
                  valueListenable: _currentImageIndex,
                  builder: (context, currentIndex, _) {
                    bool isSelected = currentIndex == index;
                    return GestureDetector(
                      onTap: () => _currentImageIndex.value = index,
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(product.images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Price
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              "${product.price.toStringAsFixed(2)} جنيه",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(width: 16),
            _buildStockBadge(),
          ],
        ),
        
        const Divider(height: 48, thickness: 1),

        // Color Selection
        Text(
          "اللون: ${product.colorName}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildColorSelector(),

        const SizedBox(height: 32),

        // Size Selection
        const Text(
          "المقاس",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildSizeSelector(),

        const SizedBox(height: 32),

        // Quantity and Add to Cart
        Row(
          children: [
            _buildQuantitySelector(),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 55,
                child: DefaultButton(
                  title: "إضافة إلى السلة", 
                  onTap: () {}, 
                  margin: EdgeInsets.zero
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Additional Info (Badges)
        if (product.badges.isNotEmpty) ...[
          const Text(
            "المميزات",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.badges.map((badge) => _buildFeatureBadge(badge)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: product.inStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            product.inStock ? Icons.check_circle : Icons.error,
            size: 16,
            color: product.inStock ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 4),
          Text(
            product.inStock ? "متوفر" : "غير متوفر",
            style: TextStyle(
              color: product.inStock ? Colors.green[800] : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.verify_copy, size: 16, color: Color(0xFF222222)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF495057)),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedSizeIndex,
      builder: (context, selectedIndex, _) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(product.sizes.length, (index) {
            final isSelected = selectedIndex == index;
            return InkWell(
              onTap: () => _selectedSizeIndex.value = index,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF222222) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF222222) : const Color(0xFFE9ECEF),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Text(
                  product.sizes[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF222222),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
        return Wrap(
          spacing: 16,
          children: List.generate(product.availableColors.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => _selectedColorIndex.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF222222) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: product.availableColors[index],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(color: Colors.white, width: 2),
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
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (_quantity.value > 1) _quantity.value--;
            },
            icon: const Icon(Icons.remove, size: 18),
            splashRadius: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ValueListenableBuilder<int>(
              valueListenable: _quantity,
              builder: (context, qty, _) => Text(
                "$qty",
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _quantity.value++,
            icon: const Icon(Icons.add, size: 18),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
