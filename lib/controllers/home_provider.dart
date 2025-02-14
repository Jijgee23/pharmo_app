// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/category.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/cart/order_done.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeProvider extends ChangeNotifier {
  void reset() {
    _searchController.clear();
    queryType = 'name';
    searchType = 'Нэрээр';
    isList = false;
    query = '';
    searching = false;
    currentIndex = 0;
    invisible = false;
    selectedCustomerName = '';
    selectedCustomerId = 0;
    userId = 0;
    selectedBranchId = -1;
    payType = 'NOW';
    branches.clear();
    branchList.clear();
    categories.clear();
  }

  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  List<String> stype = ['Нэрээр', 'Баркодоор'];
  String queryType = 'name';
  String searchType = 'Нэрээр';
  bool isList = false;
  String query = '';
  bool searching = false;
  int currentIndex = 0;
  bool invisible = false;
  String selectedCustomerName = '';
  int selectedCustomerId = 0;
  String? userEmail;
  String? userRole;
  String? userName;
  int userId = 0;
  int? basketId;
  int selectedBranchId = -1;
  String payType = 'NOW';
  String? note;
  List<Branch> branchList = <Branch>[];
  late LocationPermission permission;
  late bool servicePermission = false;
  Position? _currentLocation;
  LatLng? selectedLoc;
  double? currentLatitude;
  double? currentLongitude;
  String? cName;
  String? cRd;
  String? email;
  String? phone;
  String? detail;
  List<Category> categories = <Category>[];
  List<Manufacturer> mnfrs = <Manufacturer>[];
  List<Manufacturer> vndrs = <Manufacturer>[];
  late Map<String, dynamic> _userInfo;
  Map<String, dynamic> get userInfo => _userInfo;
  final List<Supplier> _supList = <Supplier>[];
  List<Supplier> get supList => _supList;
  String _supName = 'Нийлүүлэгч сонгох';
  String get supName => _supName;
  List<Sector> branches = <Sector>[];
  int supID = 0;
  setSupId(int? k) async {
    if (k == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('suppID');
      supID = id!;
    } else {
      supID = k;
    }
    notifyListeners();
  }

  setSelectedLoc(LatLng p) {
    selectedLoc = p;
    print(p.latitude);
    notifyListeners();
  }

  void refresh(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final promotion = Provider.of<PromotionProvider>(context, listen: false);
        clearItems();
        setPageKey(1);
        fetchProducts();
        if (promotion.markedPromotions.isNotEmpty) {
          showMarkedPromos();
        }
      },
    );
  }

  // Барааний жагсаалт & бараа хайх
  List<Product> fetchedItems = [];
  int pageKey = 1;
  final int pageSize = 100;
  setPageKey(int n) {
    pageKey = n;
    notifyListeners();
  }

  clearItems() {
    fetchedItems.clear();
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    List<Product> items = await getProducts(pageKey);
    if (items.isNotEmpty) {
      fetchedItems.addAll(items);
    }
    notifyListeners();
  }

  void fetchMoreProducts() async {
    setPageKey(pageKey + 1);
    fetchProducts();
    notifyListeners();
  }

  filterProduct(String query) async {
    clearItems();
    List<Product> items = await searchProducts(query);
    if (items.isNotEmpty) {
      fetchedItems.addAll(items);
    }
    notifyListeners();
  }

  getProducts(int pageKey) async {
    try {
      final response = await apiGet('products/?page=$pageKey&page_size=$pageSize');
      if (response.statusCode == 200) {
        final res = convertData(response);
        final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
    notifyListeners();
  }

  searchProducts(String query) async {
    try {
      if (query.isNotEmpty) {
        final response = await apiGet('products/search/?k=$queryType&v=$query');
        if (response.statusCode == 200) {
          clearItems();
          final res = convertData(response);
          final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
          return prods;
        }
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
    notifyListeners();
  }

  // хямдралтай, эрэлттэй, шинэ бараа
  filterProducts(String filter) async {
    try {
      final response = await apiGet('products/?$filter');
      if (response.statusCode == 200) {
        final res = convertData(response);
        final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        clearItems();
        fetchedItems.addAll(prods);
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on filterProduct > ${e.toString()}');
    }
    notifyListeners();
  }

  uploadImage({
    required int id,
    required List<File> images,
    // List<int>? deletion
  }) async {
    try {
      var request = http.MultipartRequest('PATCH', setUrl('update_product_image/'));
      request.headers['Authorization'] = await getAccessToken();
      request.fields['product_id'] = id.toString();

      images
          .map((image) async =>
              request.files.add(await http.MultipartFile.fromPath('images', image.path)))
          .toList();
      var res = await request.send();
      print(res.statusCode);
      String responseBody = await res.stream.bytesToString();
      print(responseBody);
      if (res.statusCode == 200) {
        return buildResponse(0, null, 'Амжилттай хадгалагдлаа');
      } else {
        message(wait);
        return buildResponse(1, null, wait);
      }
    } catch (e) {
      return buildResponse(3, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }

  deleteImages({required int id, required int imageID}) async {
    try {
      var request = http.MultipartRequest('PATCH', setUrl('update_product_image/'));
      request.headers['Authorization'] = await getAccessToken();
      request.fields['product_id'] = id.toString();
      request.fields['images_to_remove'] = imageID.toString();
      var res = await request.send();
      print(res.statusCode);
      String responseBody = await res.stream.bytesToString();
      print(responseBody);
      if (res.statusCode == 200) {
        return buildResponse(0, null, 'Амжилттай хадгалагдлаа');
      } else {
        message(wait);
        return buildResponse(1, null, wait);
      }
    } catch (e) {
      return buildResponse(2, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }

  Future getBranches() async {
    try {
      final response = await apiGet('branch/');
      if (response.statusCode == 200) {
        List<dynamic> res = convertData(response);
        branches = (res).map((data) => Sector.fromJson(data)).toList();
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // Онцлох урамшуулал харуулах
  showMarkedPromos() {
    Get.dialog(const PromotionDialog());
  }

  // Ангилалийн жагсаалт авах
  getFilters() async {
    try {
      final response = await apiGet('product/filters/');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        categories = (res['cats'] as List).map((e) => Category.fromJson(e)).toList();

        mnfrs = (res['mnfrs'] as List).map((e) => Manufacturer.fromJson(e)).toList();
        vndrs = (res['vndrs'] as List).map((e) => Manufacturer.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Бараа ангиллаар шүүх
  filter(String type, int filters, int page, int pageSize) async {
    try {
      final response = await apiGet('products/?$type=[$filters]&page=$page&page_size=$pageSize');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        List<Product> prods =
            (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  filterCate(int id, int page, int pageSize) async {
    try {
      final response = await apiGet('products/?category=[$id]&page=$page&page_size=$pageSize');
      if (response.statusCode == 200) {
        Map<String, dynamic> res = convertData(response);
        List<Product> prods =
            (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Нийлүүлэгчдийн жагсаалт авах
  getSuppliers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('suppID');
      final response = await apiGet('suppliers');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        _supList.clear();
        res.forEach((key, value) {
          var model = Supplier(key, value);
          if (id != null && int.parse(model.id) == id) {
            changeSupName(model.name);
          }
          _supList.add(model);
        });
        notifyListeners();
      } else {
        debugPrint('Түр хүлээгээд дахин оролдоно уу!');
      }
    } catch (e) {
      debugPrint('SERVER ERROR: $e');
    }
  }

  // Нийлүүлэгч сонгох
  pickSupplier(int supId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await apiPost('pick/', {'supplierId': supId});
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      await prefs.setString('access_token', res['access_token']);
      await prefs.setString('refresh_token', res['refresh_token']);
      await prefs.setInt('picked_suplier', res['id']);
      final promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
      final basketProvider = Provider.of<BasketProvider>(context, listen: false);
      await promotionProvider.getMarkedPromotion();
      await getFilters();
      await basketProvider.getBasket();
      final promotion = Provider.of<PromotionProvider>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('MARKED PROMO LENGTH ${promotion.markedPromotions.length}');
        if (promotion.markedPromotions.isNotEmpty) {
          showMarkedPromos();
        }
      });
      notifyListeners();
    } else if (response.statusCode == 403) {
      debugPrint('PERMISSION DENIED');
    } else {
      debugPrint('SERVER ERROR');
    }
  }

  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userrole = prefs.getString('userrole');
    String? username = prefs.getString('username');
    int? uid = prefs.getInt('user_id');
    userEmail = useremail.toString();
    userRole = userrole.toString();
    userId = int.parse(uid.toString());
    userName = username.toString();
    notifyListeners();
  }

  getSelectedUser(int customerId, String customerName) {
    selectedCustomerId = customerId;
    selectedCustomerName = customerName;
    notifyListeners();
  }

  // Сагсны id авах
  getBasketId() async {
    final response = await apiGet('get_basket/');
    final res = convertData(response);
    if (response.statusCode == 200) {
      basketId = res['id'];
    }
    notifyListeners();
  }

  getCustomerBranch() async {
    try {
      final response = await apiPost('seller/customer_branch/', {'customerId': selectedCustomerId});
      branchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = convertData(response);
        for (int i = 0; i < res.length; i++) {
          branchList.add(Branch.fromJson(res[i]));
        }
        selectedBranchId = res[0]['id'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getPosition() async {
    _currentLocation = await _getCurrentLocation();
    currentLatitude = double.parse(_currentLocation!.latitude.toStringAsFixed(6));
    currentLongitude = double.parse(_currentLocation!.longitude.toStringAsFixed(6));
  }

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {}
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  deactiveUser(String password, BuildContext context) async {
    try {
      final response = await apiPatch('auth/delete_user_account/', jsonEncode({'pwd': password}));
      if (response.statusCode == 200) {
        AuthController().logout(context);
        message(
          '$userEmail и-мейл хаягтай таний бүртгэл устгагдлаа',
        );
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  createSellerOrder(BuildContext context, String type) async {
    final basket = Provider.of<BasketProvider>(context, listen: false);
    try {
      Object body = {
        'customer_id': selectedCustomerId,
        'basket_id': basket.basket.id,
        'payType': type,
        "note": (note != null) ? note : null
      };
      final response = await apiPost('seller/order/', body);
      if (response.statusCode == 201) {
        final res = convertData(response);
        final orderNumber = res['orderNo'];
        goto(OrderDone(orderNo: orderNumber.toString()));
        await basket.clearBasket();
        note = null;
        notifyListeners();
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      message('Захиалга үүсгэхэд алдаа гарлаа.');
    }
  }

  setNote(String nv) {
    note = nv;
    notifyListeners();
  }

  setQueryType(String type) {
    queryType = type;
    notifyListeners();
  }

  setPayType(String v) {
    payType = v;
    notifyListeners();
  }

  setQueryTypeName(String newValue) {
    searchType = newValue;
    notifyListeners();
  }

  changeQueryValue(String? value) {
    query = value ?? '';
    notifyListeners();
  }

  changeSearching(bool a) {
    searching = a;
    notifyListeners();
  }

  changeSupName(String name) async {
    _supName = name;
    notifyListeners();
  }

  changeIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  changeSelectedCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  changeSelectedCustomerName(String customerName) {
    selectedCustomerName = customerName;
    notifyListeners();
  }

  toggleInvisible() {
    invisible = !invisible;
    notifyListeners();
  }

  switchView() {
    isList = !isList;
    notifyListeners();
  }

  // theme
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  bool fetching = false;

  setFetching(bool n) {
    fetching = n;
    notifyListeners();
  }
}
