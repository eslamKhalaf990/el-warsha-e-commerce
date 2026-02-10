import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:warsha_commerce/controllers/time_line.dart';
import 'package:warsha_commerce/view_models/cart_v_m.dart';
import 'package:warsha_commerce/view_models/product_v_m.dart';
import 'package:warsha_commerce/view_models/user_v_m.dart';

class WarshaAppBar extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;

  const WarshaAppBar({
    super.key,
    required this.isMobile,
    required this.isDesktop,
  });

  @override
  State<WarshaAppBar> createState() => _WarshaAppBarState();
}

class _WarshaAppBarState extends State<WarshaAppBar> {
  // 1. Add state to track if we are searching on mobile
  bool _isSearchingMobile = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16.0 : 40.0),
        // 2. AnimatedSwitcher for smooth transition between Search Bar and Logo
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearchingMobile && widget.isMobile
              ? _buildMobileSearchRow(context)
              : _buildDefaultRow(context),
        ),
      ),
    );
  }

  // --- MOBILE SEARCH VIEW ---
  Widget _buildMobileSearchRow(BuildContext context) {
    return Row(
      key: const ValueKey('searchRow'), // Unique key for animation
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                Provider.of<ProductVM>(context, listen: false).setSearchQuery(value);
              },
              decoration: const InputDecoration(
                hintText: "البحث عن المنتجات",
                prefixIcon: Icon(Iconsax.search_normal_1_copy, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearchingMobile = false;
              _searchController.clear();
              Provider.of<ProductVM>(context, listen: false).setSearchQuery("");
            });
          },
          icon: const Icon(Icons.close, color: Colors.black87),
        ),
      ],
    );
  }

  // --- DEFAULT LOGO & ACTIONS VIEW ---
  Widget _buildDefaultRow(BuildContext context) {
    final productVM = Provider.of<ProductVM>(context, listen: false);

    return Row(
      key: const ValueKey('defaultRow'), // Unique key for animation
      children: [
        Image.asset(
          "assets/images/logo-no-back.png",
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 40),

        // Desktop Search Bar
        if (!widget.isMobile)
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  onChanged: (value) => productVM.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: "البحث عن المنتجات",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    prefixIcon: const Icon(Iconsax.search_normal_1_copy),
                  ),
                ),
              ),
            ),
          )
        else
          const Spacer(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mobile Search Toggle Button
            if (widget.isMobile)
              IconButton(
                onPressed: () => setState(() => _isSearchingMobile = true),
                icon: const Icon(Icons.search, color: Colors.black87),
              ),

            if (!widget.isMobile)
              IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black87)),

            const SizedBox(width: 8),
            _buildIconButton(Icons.person_outline, () => Navigator.pushNamed(context, '/login')),
            const SizedBox(width: 8),

            // Cart Icon with Badge
            Consumer<CartVM>(
              builder: (context, cartVM, child) => IconButton(
                onPressed: () {
                  if (Provider.of<UserViewModel>(context, listen: false).token != "-") {
                    Provider.of<TimelineController>(context, listen: false).changePage(1);
                  }
                  Navigator.pushNamed(context, '/shopping_cart');
                },
                icon: Badge(
                  label: Text(cartVM.itemCount.toString()),
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
                ),
              ),
            ),

            const SizedBox(width: 8),
            _buildIconButton(Icons.work_history_outlined, () => Navigator.pushNamed(context, '/orders_history')),
            const SizedBox(width: 8),
            Container(height: 24, width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
            _buildIconButton(Icons.brightness_medium_outlined, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(onPressed: onPressed, icon: Icon(icon, color: Colors.black87));
  }
}