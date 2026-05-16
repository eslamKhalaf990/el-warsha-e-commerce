import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/models/category_model.dart';
import 'package:warsha_commerce/view_models/product_v_m.dart';
import 'package:warsha_commerce/views/products/poduct_card.dart';
import 'dart:math' as math;

class CategoryProductsView extends StatelessWidget {
  final CategoryModel category;

  const CategoryProductsView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<ProductVM>(
        builder: (context, vm, child) {
          final products = vm.getProductsByCategory(category.categoryId);

          if (products.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد منتجات في هذه الفئة حالياً",
                style: TextStyle(fontSize: 16),
              ),
            );
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
                horizontalPadding = 24;
              } else {
                crossAxisCount = 4;
                horizontalPadding = 32;
              }

              double cardWidth = (width - (horizontalPadding * 2) - ((crossAxisCount - 1) * 20)) / crossAxisCount;
              const double fixedContentHeight = 145.0;
              const double imageAspectRatio = 1.2;
              double cardHeight = (cardWidth * imageAspectRatio) + fixedContentHeight;
              double childAspectRatio = cardWidth / cardHeight;

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 24,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    isMobile: width < 600,
                    imageAspectRatio: imageAspectRatio,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
