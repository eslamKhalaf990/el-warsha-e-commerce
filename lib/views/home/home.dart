import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/view_models/product_v_m.dart';
import 'package:warsha_commerce/views/products/poduct_card.dart';

import 'home_app_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductVM>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
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
                physics: const BouncingScrollPhysics(), // Better feel on mobile
                slivers: [
                  WarshaAppBar(isDesktop: width >= 1100, isMobile: width < 600),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24,
                    ),
                    sliver: vm.filteredProducts!.isEmpty
                        ? const SliverToBoxAdapter(child: Center(child: Text("No products found")))
                        : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 24,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final product = vm.filteredProducts![index];

                          // Adding a Fade-in Animation for new search results
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: ProductCard(
                              key: ValueKey(product.id), // Important for animations
                              product: product,
                              isMobile: width < 600,
                              imageAspectRatio: imageAspectRatio,
                            ),
                          );
                        },
                        childCount: vm.filteredProducts!.length,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No products available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
