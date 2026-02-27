import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class HomeViewModel extends ChangeNotifier {
  final FakeStoreService _apiService = FakeStoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Product> _allProducts = [];
  List<Product> get allProducts => _allProducts;

  List<String> _categories = [];
  List<String> get categories => _categories;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    _allProducts = await _apiService.getProducts();
    
    // Extract unique categories
    final Set<String> uniqueCats = {};
    for (var product in _allProducts) {
      uniqueCats.add(product.category);
    }
    _categories = uniqueCats.toList();

    _isLoading = false;
    notifyListeners();
  }

  List<Product> getProductsByCategory(String category) {
    if (category.isEmpty) return _allProducts;
    return _allProducts.where((p) => p.category == category).toList();
  }
}
