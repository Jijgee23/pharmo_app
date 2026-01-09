import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/views/cart/order_done.dart';
import 'package:pharmo_app/views/pharmacy/promotion/promotion_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/progress_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class HomeProvider extends ChangeNotifier {
  void reset() {
    queryType = 'name';
    searchType = 'Нэрээр';
    query = '';
    currentIndex = 0;
    // selectedCustomerName = '';
    // selectedCustomerId = 0;
    branches.clear();
    branchList.clear();
    categories.clear();
    supliers.clear();
  }

  List<String> stype = ['Нэрээр', 'Баркодоор'];
  String queryType = 'name';
  String searchType = 'Нэрээр';
  bool isList = false;
  String query = '';
  int currentIndex = 0;
  // String selectedCustomerName = '';
  // int selectedCustomerId = 0;
  String? note;
  List<Branch> branchList = <Branch>[];
  late LocationPermission permission;
  late bool servicePermission = false;
  Position? _currentLocation;
  LatLng? selectedLoc;
  double? currentLatitude;
  double? currentLongitude;
  List<Category> categories = <Category>[];
  List<Manufacturer> mnfrs = <Manufacturer>[];
  List<Manufacturer> vndrs = <Manufacturer>[];
  List<Supplier> supliers = [];
  List<Sector> branches = <Sector>[];
  Supplier picked = Supplier(
    id: 1,
    name: 'Нийлүүлэгч сонгох',
    logo: null,
    stocks: [],
  );

  setSupplier(Supplier sup) {
    picked = sup;
    notifyListeners();
  }

  setSelectedLoc(LatLng p) {
    selectedLoc = p;
    notifyListeners();
  }

  void refresh(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final promotion =
            Provider.of<PromotionProvider>(context, listen: false);
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

  Future<List<Product>> getProducts(int pageKey) async {
    try {
      var url = 'products/?page=$pageKey&page_size=$pageSize';
      print(url);
      final response = await api(Api.get, url);
      if (response!.statusCode == 200) {
        final res = convertData(response);
        final prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
    return [];
  }

  searchProducts(String query) async {
    try {
      if (query.isNotEmpty) {
        final response =
            await api(Api.get, 'products/search/?k=$queryType&v=$query');
        if (response!.statusCode == 200) {
          clearItems();
          final res = convertData(response);
          final prods = (res['results'] as List)
              .map((data) => Product.fromJson(data))
              .toList();
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
      final response = await api(Api.get, 'products/?$filter');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        final prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
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
      final security = await LocalBase.getSecurity();
      if (security == null) {
        message('Нэвтэрнэ үү');
        return;
      }
      var request =
          http.MultipartRequest('PATCH', setUrl('update_product_image/'));
      request.headers['Authorization'] = security.access;
      request.fields['product_id'] = id.toString();
      images
          .map((image) async => request.files
              .add(await http.MultipartFile.fromPath('images', image.path)))
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
      final security = await LocalBase.getSecurity();
      if (security == null) {
        message('Нэвтэрнэ үү');
        return;
      }
      var request =
          http.MultipartRequest('PATCH', setUrl('update_product_image/'));
      request.headers['Authorization'] = security.access;
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
      final response = await api(Api.get, 'branch/');
      if (response!.statusCode == 200) {
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
      final response = await api(Api.get, 'product/filters/');
      if (response!.statusCode == 200) {
        Map res = convertData(response);
        categories =
            (res['cats'] as List).map((e) => Category.fromJson(e)).toList();

        mnfrs = (res['mnfrs'] as List)
            .map((e) => Manufacturer.fromJson(e))
            .toList();
        vndrs = (res['vndrs'] as List)
            .map((e) => Manufacturer.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Бараа ангиллаар шүүх
  filter(String type, int filters, int page, int pageSize) async {
    try {
      final response = await api(
          Api.get, 'products/?$type=[$filters]&page=$page&page_size=$pageSize');
      if (response!.statusCode == 200) {
        Map res = convertData(response);
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  filterCate(int id, int page, int pageSize) async {
    try {
      final response = await api(
          Api.get, 'products/?category=[$id]&page=$page&page_size=$pageSize');
      if (response!.statusCode == 200) {
        Map<String, dynamic> res = convertData(response);
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Нийлүүлэгчдийн жагсаалт авах
  Stock selected = Stock(id: -1, name: '');

  setStock(Stock stock) {
    selected = stock;
    notifyListeners();
  }

  Future getSuppliers() async {
    try {
      final response = await api(Api.get, 'suppliers_list/', showLog: true);
      if (response!.statusCode == 200) {
        final data = convertData(response);
        supliers = (data as List).map((sup) => Supplier.fromJson(sup)).toList();
        notifyListeners();
      } else {
        debugPrint('Түр хүлээгээд дахин оролдоно уу!');
      }
    } catch (e) {
      debugPrint('SERVER ERROR: $e');
    }
  }

  // Нийлүүлэгч сонгох
  pickSupplier(Supplier sup, Stock stock, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await api(Api.patch, 'select_supplier/',
        body: {'supplier_id': sup.id, 'stock_id': stock.id});
    if (response!.statusCode == 200) {
      setStock(stock);
      setSupplier(sup);
      Map<String, dynamic> res = jsonDecode(response.body);
      await prefs.setString('access_token', res['access_token']);
      final promotion = context.read<PromotionProvider>();
      final basket = context.read<BasketProvider>();
      await promotion.getMarkedPromotion();
      await getFilters();
      await basket.getBasket();
      notifyListeners();
    }
  }

  getCustomerBranch() async {
    try {
      final response = await api(Api.post, 'seller/customer_branch/',
          body: {'customerId': customer!.id});
      branchList.clear();
      if (response!.statusCode == 200) {
        List<dynamic> res = convertData(response);
        for (int i = 0; i < res.length; i++) {
          branchList.add(Branch.fromJson(res[i]));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getPosition() async {
    _currentLocation = await _getCurrentLocation();
    currentLatitude =
        double.parse(_currentLocation!.latitude.toStringAsFixed(6));
    currentLongitude =
        double.parse(_currentLocation!.longitude.toStringAsFixed(6));
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
      final response = await api(Api.patch, 'auth/delete_user_account/',
          body: {'pwd': password});
      if (response!.statusCode == 200) {
        AuthController().logout(context);
        message(
            '${LocalBase.security!.email} и-мейл хаягтай таний бүртгэл устгагдлаа');
      } else {
        message('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Customer? customer;
  void setCustomer(Customer? val) {
    customer = val;
    notifyListeners();
  }

  createSellerOrder(BuildContext context, String type) async {
    final basket = Provider.of<BasketProvider>(context, listen: false);
    try {
      var body = {
        'customer_id': customer!.id,
        'basket_id': basket.basket!.id,
        'payType': type,
        "note": (note != null) ? note : null
      };
      final response =
          await api(Api.post, 'seller/order/', body: body, showLog: true);
      if (response!.statusCode == 201) {
        final res = convertData(response);
        final orderNumber = res['orderNo'];
        goto(OrderDone(orderNo: orderNumber.toString()));
        await basket.clearBasket();
        setCustomer(null);
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

  setQueryTypeName(String newValue) {
    searchType = newValue;
    notifyListeners();
  }

  changeIndex(int index) async {
    final user = LocalBase.security;
    if (user != null && user.role == "D") {
      if (index == 0) {
        JaggerProvider jagger =
            Provider.of<JaggerProvider>(Get.context!, listen: false);
        await jagger.getDeliveries();
      }
    }
    currentIndex = index;
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

  bool loading = false;
  void setLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loading = value;
      notifyListeners();
    });
  }

  static Future initer(Future<void> Function() fetch) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (db) async {
        showPharmoProgressDialog();
        try {
          await fetch();
        } catch (e) {
          await Future.delayed(Duration(seconds: 1));
          debugPrint(e.toString());
        } finally {
          hidePharmoProgressDialog();
        }
      },
    );
  }
}
