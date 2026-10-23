import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart' hide Response, FormData, MultipartFile;
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
    productsLoaded = false;
    productFilter = allProducts;
    productScrollOffset = 0;
    picked = Supplier(
      id: 1,
      name: 'Нийлүүлэгч сонгох',
      logo: null,
      stocks: [],
    );
    orderDeliveryType = '';
    orderBranch = null;
    orderPayType = '';
    orderStep = 0;
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

  // Pharmacy ordering (OrderSheet) selections, remembered across the sheet
  // being closed/reopened the same way `note` already is — cleared once
  // via clearOrderSelections() after an order is actually placed.
  String orderDeliveryType = '';
  Sector? orderBranch;
  String orderPayType = '';
  // Which OrderSheet step the user was on — so an accidental close (the X
  // button, a swipe-down) reopens where they left off instead of at step 0.
  int orderStep = 0;

  void setOrderDeliveryType(String v) {
    orderDeliveryType = v;
    notifyListeners();
  }

  void setOrderBranch(Sector s) {
    orderBranch = s;
    notifyListeners();
  }

  void setOrderPayType(String v) {
    orderPayType = v;
    notifyListeners();
  }

  void setOrderStep(int v) {
    orderStep = v;
    notifyListeners();
  }

  void clearOrderSelections() {
    orderDeliveryType = '';
    orderBranch = null;
    orderPayType = '';
    orderStep = 0;
    notifyListeners();
  }

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
        reloadProducts();
        if (promotion.markedPromotions.isNotEmpty) {
          showMarkedPromos();
        }
      },
    );
  }

  // Барааний жагсаалт & бараа хайх
  //
  // The products tab's widget is rebuilt each time the bottom bar switches
  // back to it, so everything it shows lives here: the listing
  // (fetchedItems, pageKey), what that listing is (query, productFilter)
  // and where it was scrolled to.
  List<Product> fetchedItems = [];
  int pageKey = 1;
  int totalCount = 0;
  final int pageSize = 100;

  /// [fetchedItems] holds a loaded listing, shown as is on returning to the
  /// tab instead of fetching page 1 again.
  bool productsLoaded = false;

  static const allProducts = 'Бүгд';

  /// The products tab's quick filters: the endpoint and query each lists.
  ///
  /// «Эрэлттэй» is products_by_demand/ (the catalogue ordered by demand):
  /// supplier_indemand_products/ rows carry a demand-row id rather than the
  /// product's, and no price. There is no «Шинэ»: the API can't order by
  /// newest — products/ takes `ordering` on p_name only, hence «А–Я».
  static const quickFilters = <String, (String, Map<String, String>)>{
    'Хямдралтай': ('products/', {'discount__gt': '0'}),
    'Эрэлттэй': ('products_by_demand/', {}),
    'А–Я': ('products/', {'ordering': 'p_name'}),
  };

  /// The quick filter chip in use: [allProducts] or a [quickFilters] key.
  String productFilter = allProducts;
  void setProductFilter(String filter) {
    productFilter = filter;
    notifyListeners();
  }

  /// Last scroll position of the products list, restored on return.
  double productScrollOffset = 0;

  bool get hasMore => fetchedItems.length < totalCount;

  setPageKey(int n) {
    pageKey = n;
    notifyListeners();
  }

  // Bumped whenever the listing is replaced, so a page that arrives for an
  // older one (a search typed over, a load started before switching tabs
  // and back) is dropped instead of appended.
  int _listing = 0;

  clearItems() {
    _listing++;
    fetchedItems.clear();
    totalCount = 0;
    productsLoaded = false;
    // A new listing starts at the top.
    productScrollOffset = 0;
    notifyListeners();
  }

  /// The endpoint and query behind [fetchedItems]: the search while there is
  /// a [query], else the quick filter in use, else the whole catalogue.
  (String, Map<String, String>) get _source {
    if (query.isNotEmpty) return ('products/search/', {'k': queryType, 'v': query});
    return quickFilters[productFilter] ?? ('products/', const {});
  }

  /// Page [pageKey] of [_source], appended to [fetchedItems].
  Future<void> fetchProducts() async {
    final listing = _listing;
    final (path, params) = _source;
    final (items, count) = await productsPage(path, params, pageKey);
    if (listing != _listing) return;
    totalCount = count;
    fetchedItems.addAll(items);
    productsLoaded = true;
    notifyListeners();
  }

  /// The next page of whatever is listed.
  void fetchMoreProducts() async {
    if (!hasMore) return;
    setPageKey(pageKey + 1);
    await fetchProducts();
  }

  filterProduct(String query) async {
    this.query = query;
    productFilter = allProducts;
    clearItems();
    pageKey = 1;
    await fetchProducts();
  }

  /// Lists one of [quickFilters]. The current list stays up until its
  /// first page arrives.
  Future<void> applyQuickFilter(String name) async {
    query = '';
    productFilter = name;
    final listing = ++_listing;
    notifyListeners();
    final (path, params) = _source;
    final (items, count) = await productsPage(path, params, 1);
    if (listing != _listing) return;
    clearItems();
    pageKey = 1;
    totalCount = count;
    fetchedItems.addAll(items);
    productsLoaded = true;
    notifyListeners();
  }

  /// One page of a product listing (GET [path], e.g. products/ with its
  /// filters) and the total count the server reports for that listing.
  Future<(List<Product>, int)> productsPage(
    String path,
    Map<String, String> query,
    int page, {
    int? size,
  }) async {
    try {
      final endpoint = Uri(
        path: path,
        queryParameters: {...query, 'page': '$page', 'page_size': '${size ?? pageSize}'},
      ).toString();
      final r = await api(Api.get, endpoint);
      if (r != null && r.statusCode == 200) {
        final res = convertData(r);
        final items = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return (items, (res['count'] ?? 0) as int);
      }
    } catch (e) {
      debugPrint('error============= on $path > ${e.toString()}');
    }
    return (<Product>[], 0);
  }

  /// The whole catalogue from page 1: no search, no quick filter.
  Future<void> showAllProducts() async {
    query = '';
    productFilter = allProducts;
    clearItems();
    pageKey = 1;
    await fetchProducts();
  }

  /// Fetches again whatever the tab is showing, e.g. on pull-to-refresh or
  /// after the supplier changed.
  Future<void> reloadProducts() async {
    if (query.isNotEmpty) return await filterProduct(query);
    if (quickFilters.containsKey(productFilter)) return await applyQuickFilter(productFilter);
    await showAllProducts();
  }

  /// Adds [images] to product [id]. Each must already be at most 1MB and a
  /// jpeg/png/webp, at most 5 per call — see compressImage().
  Future uploadImage({
    required int id,
    required List<File> images,
  }) async {
    try {
      final r = await _updateProductImages({
        'product_id': id,
        'images': await Future.wait(images.map(ApiService.imagePart)),
      });
      if (r?.statusCode == 200) {
        return buildResponse(0, null, 'Амжилттай хадгалагдлаа');
      }
      return buildResponse(1, null, r == null ? wait : apiErrorMessage(apiBody(r)) ?? wait);
    } catch (e) {
      return buildResponse(3, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }

  Future<bool> deleteImages({required int id, required int imageID}) async {
    final r = await _updateProductImages({
      'product_id': id,
      'images_to_remove': [imageID],
    });
    if (r?.statusCode == 200) {
      messageComplete('Амжилттай хадгалагдлаа');
      return true;
    }
    messageWarning(r == null ? wait : apiErrorMessage(apiBody(r)) ?? wait);
    return false;
  }

  // PATCH update_product_image/ (multipart). Through ApiService.dio, which
  // adds the Bearer token and refreshes it; only the client header is set
  // here so Dio can give FormData its multipart Content-Type. On 200 the
  // body is the product's full image list.
  Future<Response?> _updateProductImages(Map<String, dynamic> fields) async {
    try {
      return await ApiService.dio.patch(
        ApiService.buildUrl('update_product_image/').toString(),
        data: FormData.fromMap(fields),
        options: Options(headers: ApiService.clientHeader),
      );
    } catch (e) {
      debugPrint('update_product_image/ failed: $e');
      return null;
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

  // Switches which branch the signed-in staff member is acting as
  // (SelectCurrentBranchView.patch) — the response carries a fresh access
  // token scoped to that branch's customer_id claim. The refresh token is
  // untouched, so Authenticator.updateAccess() is called with no `refresh:`
  // argument, mirroring the existing 401-retry flow in api.dart's
  // refreshed().
  Future<bool> selectBranch(int branchId) async {
    try {
      final r = await api(Api.patch, 'select_branch/', body: {'branch_id': branchId});
      if (r == null) return false;
      if (r.statusCode == 200) {
        final data = convertData(r);
        await Authenticator.updateAccess(data['access_token']);
        return true;
      }
      debugPrint('select_branch failed: ${convertData(r)}');
      messageWarning('Салбар сонгоход алдаа гарлаа.');
      return false;
    } catch (e) {
      debugPrint('ERROR AT selectBranch: $e');
      messageWarning(wait);
      return false;
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
      if (!context.mounted) return;
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
        if (!context.mounted) return;
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

  /// The basket was emptied: the orderer chosen for it no longer applies,
  /// and the order sheet starts over at its first step.
  void forgetCustomer() {
    customer = null;
    orderStep = 0;
    notifyListeners();
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
    // Hidden by scrolling one tab; the next starts with the bar showing.
    hidingOnScroll = false;
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
