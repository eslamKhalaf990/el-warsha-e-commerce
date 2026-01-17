import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  int id;
  String name;
  dynamic deleted;
  dynamic deletedAt;
  String description;
  double buyingPrice;
  double sellingPrice;
  double discount;
  double totalPrice;
  String imageUrl;
  String sku;
  String quantity;
  String categoryName;
  int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.deleted,
    required this.deletedAt,
    required this.description,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.discount,
    required this.totalPrice,
    required this.imageUrl,
    required this.sku,
    required this.quantity,
    required this.categoryName,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    deleted: json["deleted"],
    deletedAt: json["deletedAt"],
    description: json["description"],
    buyingPrice: json["buyingPrice"]?.toDouble(),
    sellingPrice: json["sellingPrice"]?.toDouble(),
    discount: json["discount"]?.toDouble(),
    totalPrice: json["totalPrice"]?.toDouble(),
    imageUrl: json["imageUrl"],
    sku: json["sku"],
    quantity: json["quantity"],
    categoryName: json["categoryName"],
    categoryId: json["categoryId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "deleted": deleted,
    "deletedAt": deletedAt,
    "description": description,
    "buyingPrice": buyingPrice,
    "sellingPrice": sellingPrice,
    "imageUrl": imageUrl,
    "sku": sku,
    "quantity": quantity,
    "categoryName": categoryName,
    "categoryId": categoryId,
  };
}