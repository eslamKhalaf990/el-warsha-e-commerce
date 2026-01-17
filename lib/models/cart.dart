class CartItem {
  final int id;          // Matches Product.id
  final String title;    // Matches Product.name
  final int quantity;
  final String category;
  final double totalPrice;
  final double discount;
  final double price;    // Matches Product.sellingPrice
  final String imageUrl; // Matches Product.imageUrl

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.category,
    required this.totalPrice,
    required this.discount,
    required this.price,
    required this.imageUrl,
  });

  // UX Helper: Total for this specific line item
  double get total => price * quantity;
  // double get discount => total - discount;

}