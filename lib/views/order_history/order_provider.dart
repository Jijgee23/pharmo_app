import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_filter.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> orders = <OrderModel>[];
  List<OrderModel> sellerOrders = <OrderModel>[];
  List<OrderModel> filteredsellerOrders = <OrderModel>[];
  List<Supplier> suppliers = [];
  List<Branch> branches = [];

  void reset() {
    sellerOrders.clear();
    filteredsellerOrders.clear();
    sellerFilter = const SellerOrderFilter();
    sellerOrdersLoaded = false;
    sellerScrollOffset = 0;
    orders.clear();
    ordersLoaded = false;
    ordersScrollOffset = 0;
    status = OrderStatus.all;
    process = OrderProcess.all;
    paymentMethod = PayType.unknown;
    branch = Branch(id: -1, name: 'Салбар сонгох');
    supplier = Supplier(id: -1, name: 'Нийлүүлэгч сонгох', stocks: []);
    suppliers.clear();
    branches.clear();
    notifyListeners();
  }

  // The order history tab's widget is rebuilt each time the bottom bar
  // switches back to it, so besides the lists and their filters, whether
  // they are loaded and where they were scrolled to live here too.

  /// [sellerOrders] holds a loaded list, shown as is on returning to the tab.
  bool sellerOrdersLoaded = false;
  double sellerScrollOffset = 0;

  /// [orders] (the pharmacy's) holds a loaded list, shown as is on return.
  bool ordersLoaded = false;
  double ordersScrollOffset = 0;

  /// Applied by every seller order fetch, so a refresh keeps the filters.
  SellerOrderFilter sellerFilter = const SellerOrderFilter();

  // Bumped per fetch: a response from an older one (e.g. while the user was
  // still typing) is dropped instead of overwriting a newer result.
  int _sellerRequest = 0;

  /// Sets [filter] without fetching, for a change that can't alter the
  /// result (e.g. the search type while the search box is empty).
  void setSellerFilter(SellerOrderFilter filter) {
    sellerFilter = filter;
    notifyListeners();
  }

  /// Sets [filter] and reloads the list behind the loading skeleton.
  Future<void> applySellerFilter(SellerOrderFilter filter) async {
    sellerFilter = filter;
    await loadSellerOrders();
  }

  /// Reloads the list with [sellerFilter], behind the loading skeleton.
  Future<void> loadSellerOrders() async {
    final request = ++_sellerRequest;
    // A list loaded afresh starts at the top.
    sellerScrollOffset = 0;
    setLoading(true);
    try {
      await _fetchSellerOrders(request);
    } finally {
      if (request == _sellerRequest) setLoading(false);
    }
  }

  /// Reloads the list with [sellerFilter] in place, without the skeleton.
  Future<List<OrderModel>> getSellerOrders() async {
    await _fetchSellerOrders(++_sellerRequest);
    return sellerOrders;
  }

  Future<void> _fetchSellerOrders(int request) async {
    try {
      final query = sellerFilter.toQuery();
      final endpoint = Uri(
        path: 'seller/order/',
        queryParameters: query.isEmpty ? null : query,
      ).toString();
      final r = await api(Api.get, endpoint);
      if (r == null || request != _sellerRequest) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders = ords.map((data) => OrderModel.fromJson(data)).toList();
        sellerOrdersLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future deleteSellerOrder({required int orderId}) async {
    try {
      final r = await api(Api.delete, 'seller/order/$orderId/');
      if (r == null) return;
      if (r.statusCode == 204) {
        messageComplete('Захиалга устлаа');
        await getSellerOrders();
      } else {
        if (convertData(r).toString().contains('order_not_deletable')) {
          messageError('Устгах боломжгүй захиалга!');
          return;
        }
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e);
    }
  }

  bool loading = false;

  void setLoading(bool val) {
    loading = val;
    notifyListeners();
  }

  Future<dynamic> getSuppliers() async {
    try {
      final r = await api(Api.get, 'suppliers_list/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        suppliers = (data as List).map((k) => Supplier.fromJson(k)).toList();
        notifyListeners();
      }
    } catch (e) {
      messageWarning('Өгөгдөл татаж чадсангүй!');
    }
  }

  Future<dynamic> getBranches() async {
    try {
      final r = await api(Api.get, 'branch/orderer');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        branches = (data as List).map((r) => Branch.fromJson(r)).toList();
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  OrderStatus status = OrderStatus.all;
  void updateStatus(OrderStatus? value) async {
    if (value == null) return;
    status = value;
    await _refilterOrders();
  }

  OrderProcess process = OrderProcess.all;
  void updateProcess(OrderProcess? value) async {
    if (value == null) return;
    process = value;
    await _refilterOrders();
  }

  PayType paymentMethod = PayType.unknown;
  void updatePayMethod(PayType? value) async {
    if (value == null) return;
    paymentMethod = value;
    await _refilterOrders();
  }

  Branch branch = Branch(id: -1, name: 'Салбар сонгох');
  void updateBranch(Branch? value) async {
    if (value == null) return;
    branch = value;
    await _refilterOrders();
  }

  Supplier supplier = Supplier(id: -1, name: 'Нийлүүлэгч сонгох', stocks: []);
  void updateSupplier(Supplier? value) async {
    if (value == null) return;
    supplier = value;
    await _refilterOrders();
  }

  // A filter changed: the new list starts at the top.
  Future<void> _refilterOrders() async {
    ordersScrollOffset = 0;
    notifyListeners();
    await filterOrders();
  }

  // Bumped per pharmacy order fetch, so a response to an older filter
  // (several changed in a row) can't overwrite the newest one.
  int _ordersRequest = 0;

  Future<dynamic> filterOrders() async {
    final request = ++_ordersRequest;
    try {
      String url = 'pharmacy/orders/?status=${status.value}';
      if (process != OrderProcess.all) {
        url = '$url&process=${process.code}';
      }
      if (paymentMethod != PayType.unknown) {
        url = '$url&payType=${paymentMethod.value}';
      }
      if (branch.id != -1) {
        url = '$url&addrs=${branch.id}';
      }
      if (supplier.id != -1) {
        url = '$url&supplier=${supplier.id}';
      }

      final r = await api(Api.get, url);
      if (r == null || request != _ordersRequest) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['orders'];
        orders = (ords).map((data) => OrderModel.fromJson(data)).toList();
        ordersLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future confirmOrder(int orderId) async {
    try {
      var b = {"id": orderId};
      final r = await api(Api.patch, pharmConfirmOrder, body: b);
      if (r == null) return;
      switch (r.statusCode) {
        case 200:
          await filterOrders();
          return messageComplete('Таны захиалга амжилттай баталгаажлаа.');
        case 400:
          return messageWarning('Захиалгын түгээлт эхлээгүй');
        default:
          return messageError('Түр хүлээгээд дахин оролдно уу!');
      }
    } catch (e) {
      return messageError('Түр хүлээгээд дахин оролдно уу!');
    }
  }
}
