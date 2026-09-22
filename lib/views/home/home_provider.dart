import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart'
    hide Response, FormData, MultipartFile;
import 'package:pharmo_app/views/promotion/promotion_dialog.dart';

class HomeProvider extends ChangeNotifier {
  void reset() {
    queryType = 'name';
    searchType = 'Нэрээр';
    query = '';
    currentIndex = 0;
    branches.clear();
    branchList.clear();
    categories.clear();
    supliers.clear();
    mnfrs.clear();
    vndrs.clear();
    branches.clear();
    fetchedItems.clear();
    picked = Supplier(
      id: 1,
      name: 'Нийлүүлэгч сонгох',
      logo: null,
      stocks: [],
    );
    notifyListeners();
  }

  bool hidingOnScroll = false;
  void setHidingOnScroll(bool val) {
    hidingOnScroll = val;
    notifyListeners();
  }

  List<String> stype = ['Нэрээр', 'Баркодоор'];
  String queryType = 'name';
  String searchType = 'Нэрээр';
  bool isList = false;
  String query = '';
  int currentIndex = 0;
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
  int totalCount = 0;
  final int pageSize = 100;

  bool get hasMore => fetchedItems.length < totalCount;

  setPageKey(int n) {
    pageKey = n;
    notifyListeners();
  }

  clearItems() {
    fetchedItems.clear();
    totalCount = 0;
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
    if (!hasMore) return;
    setPageKey(pageKey + 1);
    await fetchProducts();
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
      final r = await api(Api.get, url);
      if (r == null) return [];
      if (r.statusCode == 200) {
        final res = convertData(r);
        totalCount = res['count'] ?? 0;
        final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
    return [];
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.isNotEmpty) {
        final url = 'products/search/?k=$queryType&v=$query&page=$pageKey&page_size=$pageSize';
        final r = await api(Api.get, url);
        if (r == null) return [];
        if (r.statusCode == 200) {
          final res = convertData(r);
          totalCount = res['count'] ?? 0;
          final prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
          return prods;
        }
      }
    } catch (e) {
      debugPrint('error============= on getProduct> ${e.toString()}');
    }
    return [];
  }

  // хямдралтай, эрэлттэй, шинэ бараа
  filterProducts(String filter) async {
    try {
      final r = await api(Api.get, 'products/?$filter');
      if (r == null) return;
      if (r.statusCode == 200) {
        final res = convertData(r);
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

  Future uploadImage({
    required int id,
    required List<File> images,
  }) async {
    try {
      final security = await Authenticator.getSecurity();
      if (security == null) {
        messageWarning('Нэвтэрнэ үү');
        return;
      }
      final formData = FormData.fromMap({
        'product_id': id.toString(),
        'images': await Future.wait(
          images.map((image) => MultipartFile.fromFile(image.path)),
        ),
      });
      final res = await ApiService.plainDio.patch(
        ApiService.buildUrl('update_product_image/').toString(),
        data: formData,
        options: Options(headers: {'Authorization': security.access}),
      );
      print(res.statusCode);
      print(res.data);
      if (res.statusCode == 200) {
        return buildResponse(0, null, 'Амжилттай хадгалагдлаа');
      } else {
        messageWarning(wait);
        return buildResponse(1, null, wait);
      }
    } catch (e) {
      return buildResponse(3, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }

  Future<bool> deleteImages({required int id, required int imageID}) async {
    try {
      final security = await Authenticator.getSecurity();
      if (security == null) {
        messageWarning('Нэвтэрнэ үү');
        return false;
      }
      final formData = FormData.fromMap({
        'product_id': id.toString(),
        'images_to_remove': imageID.toString(),
      });
      final r = await ApiService.plainDio.patch(
        ApiService.buildUrl('update_product_image/').toString(),
        data: formData,
        options: Options(headers: {'Authorization': security.access}),
      );
      if (r.statusCode == 200) {
        messageComplete('Амжилттай хадгалагдлаа');
        return true;
      } else {
        messageWarning(wait);
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future getBranches() async {
    try {
      final r = await api(Api.get, 'branch/orderer');
      if (r == null) return;
      if (r.statusCode == 200) {
        final res = convertData(r);
        print("fisrt branch ${res[0]}");
        branches = (res as List).map((data) => Sector.fromJson(data)).toList();
        notifyListeners();
      }
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
      final r = await api(Api.get, 'product/filters/');
      if (r == null) return;
      if (r.statusCode == 200) {
        Map res = convertData(r);
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
      final r = await api(Api.get, 'products/?$type=[$filters]&page=$page&page_size=$pageSize');
      if (r!.statusCode == 200) {
        Map res = convertData(r);
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
      final r = await api(Api.get, 'products/?category=[$id]&page=$page&page_size=$pageSize');
      if (r!.statusCode == 200) {
        Map<String, dynamic> res = convertData(r);
        List<Product> prods =
            (res['results'] as List).map((data) => Product.fromJson(data)).toList();
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
      final r = await api(Api.get, 'suppliers_list/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        final user = Authenticator.security;
        if (user == null) return;
        if (user.isPharmacist) {
          supliers = (data as List).map((sup) => Supplier.fromJson(sup)).toList();
        } else {
          supliers = (data as List)
              .map((sup) => Supplier.fromJson(sup))
              .where((e) => e.id == (user.byId ?? user.supplierId))
              .toList();
        }
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
    var body = {'supplier_id': sup.id, 'stock_id': stock.id};
    final r = await api(Api.patch, 'select_supplier/', body: body);
    if (r == null) {
      messageWarning('Сервертэй холбогдож чадсангүй!');
      return;
    }
    if (r.statusCode == 200) {
      setStock(stock);
      setSupplier(sup);
      Map<String, dynamic> res = convertData(r);
      await Authenticator.updateAccess(
        res['access_token'],
        refresh: res['refresh_token'],
      );
      await Authenticator.updateStock(sup.id, stock.id);
      await Authenticator.initAuthenticator();
      final promotion = context.read<PromotionProvider>();
      final basket = context.read<CartProvider>();
      await promotion.getMarkedPromotion();
      await getFilters();
      await basket.getBasket();
      notifyListeners();
    }
  }

  Future getCustomerBranch() async {
    try {
      if (customer == null) return;
      final res = await api(
        Api.post,
        'seller/customer_branch/',
        body: {'customerId': customer!.id},
      );
      if (res == null) return;
      if (res.statusCode == 200) {
        branchList = (convertData(res) as List).map((j) => Branch.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Салбарын мэдээлэл авахад алдаа гарлаа');
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
      final r = await api(Api.patch, 'auth/delete_user_account/', body: {'pwd': password});
      if (r == null) return;
      if (r.statusCode == 200) {
        AuthController().logout(context);
        messageWarning(
          '${Authenticator.security!.email} и-мейл хаягтай таний бүртгэл устгагдлаа',
        );
      } else {
        messageWarning('Алдаа гарлаа');
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

  Future createSellerOrder(BuildContext context, String type) async {
    await LoadingService.run(() async {
      try {
        final basket = context.read<CartProvider>();
        var body = {
          'customer_id': customer!.id,
          'basket_id': basket.basket!.id,
          'payType': type,
          "note": (note != null) ? note : null
        };
        final r = await api(Api.post, 'seller/order/', body: body);
        if (r == null) return;
        final res = convertData(r);
        if (r.statusCode == 201) {
          final orderNumber = res['orderNo'];
          await basket.clearBasket();
          setCustomer(null);
          note = null;
          notifyListeners();
          // seller/order/ can create more than one actual order
          // (split_group) and auto-attaches a QPay invoice to whichever
          // ones need one (a cash-only group) - each order's own
          // `requires_payment`/`qpay` live inside the response's `orders`
          // list, not at the top level. QPay must never stop the sale
          // from being recorded, so the order(s) already exist either way
          // - this only decides whether to resolve payment before
          // treating checkout as "done".
          final subOrders = SellerSubOrder.listFrom(res);
          final needsPayment =
              subOrders.where((o) => o.requiresPayment && o.qpay != null).firstOrNull;
          if (needsPayment != null) {
            goto(SellerQpayPage(
              orderId: needsPayment.id,
              orderNo: needsPayment.orderNo,
              totalPrice: needsPayment.totalPrice,
              totalCount: needsPayment.totalCount,
              invoice: needsPayment.qpay!,
            ));
          } else {
            goto(OrderDone(orderNo: orderNumber.toString()));
          }
        } else {
          if (res.toString().contains('Customer not verified')) {
            messageWarning('Баталгаажаагүй харилцагч байна!');
            return;
          }
          messageWarning('Түр хүлээнэ үү!');
          return;
        }
      } catch (e) {
        print(e);
        messageWarning('Захиалга үүсгэхэд алдаа гарлаа.');
      }
    });
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        loading = value;
        notifyListeners();
      },
    );
  }
}

class HomeScrollListener extends StatelessWidget {
  final Widget xchild;
  const HomeScrollListener({super.key, required this.xchild});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.idle) {
            return false;
          }
          home.setHidingOnScroll(notification.direction != ScrollDirection.forward);
          return false;
        },
        child: xchild,
      ),
    );
  }
}
