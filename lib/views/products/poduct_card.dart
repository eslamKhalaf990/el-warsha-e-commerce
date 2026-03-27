import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/models/product_model.dart';
import 'package:warsha_commerce/services/base_url.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/image_helper.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/views/products/product_details.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isMobile;
  final double imageAspectRatio;

  const ProductCard({
    super.key,
    required this.product,
    required this.isMobile,
    this.imageAspectRatio = 1.2,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  bool _isHovered = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final sellingPrice = widget.product.sellingPrice.toStringAsFixed(2);
    final priceAfterDiscount = widget.product.totalPrice.toStringAsFixed(2);

    final int stock = int.tryParse(widget.product.quantity) ?? 0;
    final double discount = (widget.product.discount);
    final bool isOutOfStock = stock <= 0;
    final bool isDiscountApplied = discount > 0.0;
    final cart = Provider.of<CartVM>(context);
    final isInCart = cart.items.containsKey(widget.product.id);
    final currentQty = isInCart ? cart.items[widget.product.id]!.quantity : 0;

    super.build(context);

    return MouseRegion(
      cursor: isOutOfStock
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isOutOfStock ? null : () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(
          //   product: ProductModel(
          //     title: widget.product.name,
          //     price: widget.product.sellingPrice,
          //     images: ["${Baseurl.baseURLImages}${ImageHelper.extractFileId(widget.product.imageUrl)}"], // Replace with your image
          //     availableColors: [Colors.black, Colors.grey[800]!, Colors.red[400]!], // Silver color
          //     colorName: "Silver",
          //     sizes: ["16mm / us 6", "17mm / us 7", "18mm / us 8", "19mm / us 9", "20mm / us 10"],
          //     inStock: true,
          //     badges: ["1 Year Color Warranty", "Buy 2 Get 1 Free"],
          //   ),
          // )));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered && !widget.isMobile ? -4.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: Constants.BORDER_RADIUS_5,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. IMAGE SECTION (AspectRatio enforced) ---
              AspectRatio(
                aspectRatio:
                    1 /
                    widget.imageAspectRatio, // Invert for AspectRatio widget
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: Opacity(
                        opacity: isOutOfStock ? 0.6 : 1.0,
                        child: CachedNetworkImage(
                          // Simply combine your base URL and the database path
                          imageUrl:
                          "${Baseurl.baseURLImages}${ImageHelper.extractFileId(widget.product.imageUrl)}",
                          fit: BoxFit.cover,
                          memCacheWidth: 400,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: isOutOfStock
                          ? _buildBadge("SOLD OUT", Colors.grey[800]!)
                          : isDiscountApplied ? _buildBadge("DISCOUNT", Colors.red) :_buildBadge("NEW", Colors.black),
                    ),

                    // Favorite Icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: _isFavorite ? Colors.red : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Desktop Hover Overlay

                    // ... inside your Stack or Layout ...
                    if (!widget.isMobile && !isOutOfStock)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        // UX Logic: If it's in the cart, keep it visible so user sees the quantity
                        // Otherwise, only show on hover.
                        opacity: _isHovered || isInCart ? 1.0 : 0.0,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 36,
                            // SWITCHER: Show Counter if added, else show ADD button
                            child: isInCart
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: Constants.BORDER_RADIUS_5,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Decrement
                                        _webIconButton(
                                          Icons.remove,
                                          () => cart.decrementItemQty(
                                            widget.product.id,
                                          ),
                                        ),

                                        // Quantity Text
                                        Text(
                                          "$currentQty",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),

                                        // Increment
                                        _webIconButton(
                                          Icons.add,
                                          () => cart.addToCart(widget.product),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      cart.addToCart(widget.product);
                                      // Optional: Simple feedback if you prefer not to use the counter switch immediately
                                      // But the switch to counter IS the feedback.
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets
                                          .zero, // Remove padding to fit height
                                      shape: RoundedRectangleBorder(
                                        borderRadius: Constants.BORDER_RADIUS_5,
                                      ),
                                    ),
                                    child: const Text(
                                      "أضف الي السلة",
                                      style: TextStyle(
                                        fontSize:
                                            11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- 2. TEXT DETAILS (Flexible logic) ---
              // We use Expanded here to fill the remaining space calculated by our grid formula
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Pushes price to bottom
                    children: [
                      // Top Part: Category & Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.categoryName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.name,
                            maxLines: 2, // Limit to 2 lines
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13, // Slightly smaller for better fit
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      // Bottom Part: Price & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 1. Price Section
                          Column(
                            children: [
                              isDiscountApplied ? Text(
                                "EGP $priceAfterDiscount",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isOutOfStock
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ) : Container(),
                              const SizedBox(width: 4),
                              Text(
                                "EGP $sellingPrice",
                                style: TextStyle(
                                  decoration: isDiscountApplied
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isOutOfStock || isDiscountApplied
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),

                          // 2. The Smart Action Button
                          if (widget.isMobile && !isOutOfStock)
                            InkWell(
                              // <--- UX: Adds ripple effect on tap
                              borderRadius: BorderRadius.circular(
                                50,
                              ), // Matches container shape
                              onTap: () {
                                // A. LOGIC: Add to cart
                                // listen: false because we don't need to rebuild THIS widget when cart changes
                                Provider.of<CartVM>(
                                  context,
                                  listen: false,
                                ).addToCart(widget.product);

                                // B. UX: Feedback (Crucial for Web/Mobile)
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar(); // Remove old ones immediately
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ' تم اضافة ${widget.product.name} للسلة ',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior
                                        .floating, // Floats above bottom nav
                                    backgroundColor: Colors.black,
                                    action: SnackBarAction(
                                      label: 'تراجع',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Optional: Add logic to remove the item instantly
                                        Provider.of<CartVM>(
                                          context,
                                          listen: false,
                                        ).decrementItemQty(widget.product.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(
                                  8,
                                ), // Increased touch target slightly
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  // UX: Add subtle shadow to make it lift off the card
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _webIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: Constants.BORDER_RADIUS_5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
