import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:warsha_commerce/models/category_model.dart';
import 'package:warsha_commerce/models/product_model.dart';
import 'package:warsha_commerce/services/products_service.dart';

class ProductVM extends ChangeNotifier {
  final ProductService _productService;

  bool isProductsLoading = false;
  bool isCategoriesLoading = false;

  bool get isLoading => isProductsLoading || isCategoriesLoading;

  String searchQuery = "";
  int? selectedCategoryId;

  int _pageSize = 12;
  int _currentPage = 1;

  List<Product>? allProducts;
  List<CategoryModel>? allCategories;
  Map<int, List<Product>> _categoryProductsMap = {};
  final TextEditingController searchController = TextEditingController();

  ProductVM(this._productService) {
    initAllProducts();
    searchController.addListener(() {
      notifyListeners();
    });
  }

  Future<void> initAllProducts () async {
    allProducts = await getAllProducts();
    allCategories = await getAllCategories();
    _updateCategoryProductsMap();
    notifyListeners();
  }

  void _updateCategoryProductsMap() {
    _categoryProductsMap = {};
    if (allProducts != null) {
      for (var product in allProducts!) {
        _categoryProductsMap.putIfAbsent(product.categoryId, () => []).add(product);
      }
    }
  }

  List<Product> getProductsByCategory(int categoryId) {
    return _categoryProductsMap[categoryId] ?? [];
  }

  List<Product>? get filteredProducts {
    if (allProducts == null) return null;
    
    return allProducts!.where((p) {
      bool matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategoryId == null || p.categoryId == selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Product>? get displayedProducts {
    final filtered = filteredProducts;
    if (filtered == null) return null;
    return filtered.take(_currentPage * _pageSize).toList();
  }

  bool get hasMore {
    final filtered = filteredProducts;
    if (filtered == null) return false;
    return filtered.length > (_currentPage * _pageSize);
  }

  void loadMore() {
    if (hasMore) {
      _currentPage++;
      notifyListeners();
    }
  }

  void resetPagination() {
    _currentPage = 1;
  }

  void setCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    resetPagination();
    notifyListeners();
  }

  Future<List<Product>> getAllProducts() async {
    List<Product> products = [];
    try {
      isProductsLoading = true;
      notifyListeners();
      final response = await _productService.getAllProducts("");
      if (response.statusCode == 200) {
        final productsData = jsonDecode(response.body);
        final List<dynamic> data = productsData;
        products = data.map((item) => Product.fromJson(item)).toList();
      } else {
        debugPrint("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      isProductsLoading = false;
      notifyListeners();
    }
    return products;
  }

  Future<List<CategoryModel>> getAllCategories() async {
    List<CategoryModel> categories = [];
    try {
      isCategoriesLoading = true;
      notifyListeners();
      final response = await _productService.getAllCategories("");
      if (response.statusCode == 200) {
        final categoriesData = jsonDecode(response.body);
        final List<dynamic> data = categoriesData;
        categories = data.map((item) => CategoryModel.fromJson(item)).toList();
      } else {
        debugPrint("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      isCategoriesLoading = false;
      notifyListeners();
    }
    return categories;
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    resetPagination();
    notifyListeners();
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

}
