import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/views/promotion/promotion_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/application/application.dart';

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
      final r = await api(Api.get, url);
      if (r == null) return [];
      if (r.statusCode == 200) {
        final res = convertData(r);
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
        final r = await api(Api.get, 'products/search/?k=$queryType&v=$query');
        if (r == null) return;
        if (r.statusCode == 200) {
          clearItems();
          final res = convertData(r);
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
      final r = await api(Api.get, 'products/?$filter');
      if (r == null) return;
      if (r.statusCode == 200) {
        final res = convertData(r);
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

  Future uploadImage({
    required int id,
    required List<File> images,
  }) async {
    try {
      final security = await LocalBase.getSecurity();
      if (security == null) {
        messageWarning('Нэвтэрнэ үү');
        return;
      }
      var request = http.MultipartRequest(
          'PATCH', ApiService.buildUrl('update_product_image/'));
      request.headers['Authorization'] = security.access;
      request.fields['product_id'] = id.toString();
      images
          .map((image) async => request.files
              .add(await http.MultipartFile.fromPath('images', image.path)))
          .toList();
      var res = await request.send();
      print(res.statusCode);
      String rBody = await res.stream.bytesToString();
      print(rBody);
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

  deleteImages({required int id, required int imageID}) async {
    try {
      final security = await LocalBase.getSecurity();
      if (security == null) {
        messageWarning('Нэвтэрнэ үү');
        return;
      }
      final uri = ApiService.buildUrl('update_product_image/');
      var request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = security.access;
      request.fields['product_id'] = id.toString();
      request.fields['images_to_remove'] = imageID.toString();
      var r = await request.send();
      if (r == null) return;
      // String rBody = await r.stream.bytesToString();
      if (r.statusCode == 200) {
        return buildResponse(0, null, 'Амжилттай хадгалагдлаа');
      } else {
        messageWarning(wait);
        return buildResponse(1, null, wait);
      }
    } catch (e) {
      return buildResponse(2, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }

  Future getBranches() async {
    try {
      final r = await api(Api.get, 'branch/');
      if (r == null) return;
      if (r.statusCode == 200) {
        List<dynamic> res = convertData(r);
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
      final r = await api(Api.get, 'product/filters/');
      if (r == null) return;
      if (r.statusCode == 200) {
        Map res = convertData(r);
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
      final r = await api(
          Api.get, 'products/?$type=[$filters]&page=$page&page_size=$pageSize');
      if (r!.statusCode == 200) {
        Map res = convertData(r);
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
      final r = await api(
          Api.get, 'products/?category=[$id]&page=$page&page_size=$pageSize');
      if (r!.statusCode == 200) {
        Map<String, dynamic> res = convertData(r);
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
      final r = await api(Api.get, 'suppliers_list/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
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
    var body = {'supplier_id': sup.id, 'stock_id': stock.id};
    final r = await api(Api.patch, 'select_supplier/', body: body);
    if (r == null) {
      messageWarning('Сервертэй холбогдож чадсангүй!');
      return;
    }
    if (r.statusCode == 200) {
      setStock(stock);
      setSupplier(sup);
      Map<String, dynamic> res = jsonDecode(r.body);
      await LocalBase.updateAccess(
        res['access_token'],
        refresh: res['refresh_token'],
      );
      await LocalBase.updateStock(sup.id, stock.id);
      await LocalBase.initLocalBase();
      final promotion = context.read<PromotionProvider>();
      final basket = context.read<BasketProvider>();
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
        branchList =
            (convertData(res) as List).map((j) => Branch.fromJson(j)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Салбарын мэдээлэл авахад алдаа гарлаа');
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
      final r = await api(Api.patch, 'auth/delete_user_account/',
          body: {'pwd': password});
      if (r == null) return;
      if (r.statusCode == 200) {
        AuthController().logout(context);
        messageWarning(
          '${LocalBase.security!.email} и-мейл хаягтай таний бүртгэл устгагдлаа',
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
    final basket = Provider.of<BasketProvider>(context, listen: false);
    try {
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
        goto(OrderDone(orderNo: orderNumber.toString()));
        await basket.clearBasket();
        setCustomer(null);
        note = null;
        notifyListeners();
      } else {
        if (res.toString().contains('Customer not verified')) {
          messageWarning('Баталгаажаагүй харилцагч байна!');
          return;
        }
        messageWarning('Түр хүлээнэ үү!');
        return;
      }
    } catch (e) {
      messageWarning('Захиалга үүсгэхэд алдаа гарлаа.');
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
