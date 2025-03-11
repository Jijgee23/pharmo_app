import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/models/products.dart';

class ProductProvider extends ChangeNotifier {
  int pageKey = 1;
  final int pageSize = 20;
  List<Product> products = [];
  setItems(List<Product> items) {
    products.addAll(items);
    notifyListeners();
  }

  setPageKey(int n) {
    pageKey = n;
    notifyListeners();
  }

  filterItems(List<Product> items) {
    setPageKey(1);
    products.clear();
    products.addAll(items);
    notifyListeners();
  }

  // getProducts() async {
  //   try {
  //     final response = await apiGet('products/?page=$pageKey&page_size=$pageSize');
  //     if (response.statusCode == 200) {
  //       final res = convertData(response);
  //       final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
  //       return prods;
  //     }
  //   } catch (e) {
  //     debugPrint('error============= on getProduct> ${e.toString()}');
  //   }
  //   notifyListeners();
  // }
}
