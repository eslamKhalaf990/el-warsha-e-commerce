import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/view_models/product_v_m.dart';
import 'package:warsha_commerce/views/category_products/category_products_view.dart';
import 'package:warsha_commerce/views/products/poduct_card.dart';

import 'home_app_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _arabicOffers = [
    {
      'title': 'عروض الصيف',
      'subtitle': 'خصم يصل إلى ٥٠٪ على جميع المنتجات',
      'icon': Iconsax.sun_1_copy,
      'color': const Color(0xFFFF9966),
      'secondaryColor': const Color(0xFFFF5E62),
    },
    {
      'title': 'وصلنا حديثاً',
      'subtitle': 'تصفح أحدث التشكيلات العصرية والمميزة',
      'icon': Iconsax.box_add_copy,
      'color': const Color(0xFF2193b0),
      'secondaryColor': const Color(0xFF6dd5ed),
    },
    {
      'title': 'عروض حصرية',
      'subtitle': 'استخدم الكود WARSHA للحصول على خصم إضافي',
      'icon': Iconsax.flash_1_copy,
      'color': const Color(0xFFee0979),
      'secondaryColor': const Color(0xFFff6a00),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final vm = Provider.of<ProductVM>(context, listen: false);
      if (vm.hasMore) {
        vm.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductVM>(
        builder: (context, vm, child) {
          if (vm.isLoading && (vm.allProducts == null || vm.allProducts!.isEmpty)) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            );
          }

          if (vm.allProducts == null || vm.allProducts!.isEmpty) {
            return _buildEmptyState();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              int crossAxisCount;
              double horizontalPadding;

              if (width < 450) {
                crossAxisCount = 2;
                horizontalPadding = 16;
              } else if (width < 900) {
                crossAxisCount = 3;
                horizontalPadding = 32;
              } else if (width < 1400) {
                crossAxisCount = 4;
                horizontalPadding = 64;
              } else {
                crossAxisCount = 5;
                horizontalPadding = (width - 1400) / 2;
              }
              double cardWidth = (width - (horizontalPadding * 2) - ((crossAxisCount - 1) * 20)) / crossAxisCount;
              const double fixedContentHeight = 145.0;
              const double imageAspectRatio = 1.2;

              double cardHeight = (cardWidth * imageAspectRatio) + fixedContentHeight;

              double childAspectRatio = cardWidth / cardHeight;

              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  WarshaAppBar(isDesktop: width >= 1100, isMobile: width < 600),

                  // 3. Flash Sale Banner
                  SliverToBoxAdapter(child: _buildFlashSaleSection(width)),

                  // 4. Horizontal "New Arrivals"
                  if (vm.allProducts != null && vm.allProducts!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildHorizontalSection(
                        context, 
                        title: "وصلنا حديثاً", 
                        products: vm.allProducts!.take(8).toList(),
                        width: width,
                        style: ProductCardStyle.modern,
                      ),
                    ),

                  // 5. Category-specific Sections
                  if (vm.allCategories != null && vm.allProducts != null)
                    ...vm.allCategories!.take(6).map((category) {
                      final categoryProducts = vm.getProductsByCategory(category.categoryId);
                      if (categoryProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                      return SliverToBoxAdapter(
                        child: _buildHorizontalSection(
                          context,
                          title: category.name,
                          products: categoryProducts.take(8).toList(),
                          width: width,
                          style: ProductCardStyle.slim,
                          onSeeMore: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryProductsView(category: category),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                  // 6. Main Product Grid with Split Sections
                  if (vm.displayedProducts!.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(child: Text("No products found")),
                      ),
                    )
                  else ..._buildSections(vm.displayedProducts!, crossAxisCount, childAspectRatio, imageAspectRatio, horizontalPadding, width),

                  if (vm.hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildSections(List<dynamic> products, int crossAxisCount, double childAspectRatio, double imageAspectRatio, double horizontalPadding, double width) {
    List<Widget> sections = [];
    int productsPerSection = crossAxisCount * 2;
    int totalProducts = products.length;

    for (int i = 0; i < totalProducts; i += productsPerSection) {
      int end = math.min(i + productsPerSection, totalProducts);
      
      // Grid Section
      sections.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 20,
              mainAxisSpacing: 24,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[i + index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ProductCard(
                    key: ValueKey(product.id),
                    product: product,
                    isMobile: width < 600,
                    imageAspectRatio: imageAspectRatio,
                  ),
                );
              },
              childCount: end - i,
            ),
          ),
        ),
      );

      // Offer Banner (if there are more products or it's the end of a section)
      if (end < totalProducts) {
        int offerIndex = (i ~/ productsPerSection) % _arabicOffers.length;
        sections.add(
          SliverToBoxAdapter(
            child: _buildOfferBanner(width, _arabicOffers[offerIndex]),
          ),
        );
      }
    }

    return sections;
  }

  Widget _buildFlashSaleSection(double width) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.amber.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.timer_copy, color: Colors.amber, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "تنتهي خلال 05:00:00",
                                  style: TextStyle(
                                    color: Colors.amber, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "تخفيضات البرق",
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 28, 
                              fontWeight: FontWeight.w900, 
                              height: 1.2,
                            ),
                          ),
                          const Text(
                            "خصومات هائلة تصل إلى ٧٠٪ لفترة محدودة",
                            style: TextStyle(
                              color: Colors.grey, 
                              fontSize: 14, 
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "استفد من العرض", 
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (width > 500) ...[
                    const SizedBox(width: 20),
                    const Hero(
                      tag: 'flash_sale_icon',
                      child: Icon(Iconsax.flash_1_copy, size: 100, color: Colors.amber),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(BuildContext context, {required String title, required List<dynamic> products, required double width, VoidCallback? onSeeMore, ProductCardStyle style = ProductCardStyle.standard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onSeeMore ?? () {},
                  child: Row(
                    children: [
                      Text("عرض الكل", style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(Iconsax.arrow_left_2_copy, size: 14, color: Theme.of(context).colorScheme.tertiary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: width < 600 ? 300 : 360,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Container(
                width: width < 600 ? 170 : 230,
                margin: const EdgeInsets.only(left: 16),
                child: ProductCard(
                  product: products[index],
                  isMobile: true,
                  imageAspectRatio: 1.1,
                  style: style,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferBanner(double width, Map<String, dynamic> offer) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 32),
      height: width < 600 ? 200 : 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            offer['color'],
            offer['secondaryColor'],
          ],
        ),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned(
              left: -40,
              bottom: -40,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  offer['icon'],
                  size: width < 600 ? 220 : 380,
                  color: Colors.white,
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width < 600 ? 24 : 80),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              offer['icon'],
                              color: Colors.white,
                              size: width < 600 ? 24 : 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            offer['title']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width < 600 ? 32 : 56,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            offer['subtitle']!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: width < 600 ? 15 : 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: offer['color'],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'تسوق الآن',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (width >= 800)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Icon(
                          offer['icon'],
                          size: 180,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.box_search_copy, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            "لا توجد منتجات حالياً",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "حاول البحث بكلمات أخرى أو تصفح فئات مختلفة",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
