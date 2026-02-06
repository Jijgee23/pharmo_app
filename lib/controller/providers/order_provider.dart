import 'package:pharmo_app/application/application.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> orders = <OrderModel>[];
  List<OrderModel> sellerOrders = <OrderModel>[];
  List<OrderModel> filteredsellerOrders = <OrderModel>[];
  List<Supplier> suppliers = [];
  List<Branch> branches = [];

  void reset() {
    sellerOrders.clear();
    filteredsellerOrders.clear();
    orders.clear();
    suppliers.clear();
    branches.clear();
    notifyListeners();
  }

  Future<List<OrderModel>> getSellerOrders() async {
    List<OrderModel> rult = [];
    try {
      final r = await api(Api.get, 'seller/order/');
      if (r == null) return rult;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders.clear();
        sellerOrders = (ords).map((data) => OrderModel.fromJson(data)).toList();
        rult = sellerOrders;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return rult;
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

  Future filterOrder(String type, String query) async {
    try {
      final r = await api(Api.get, 'seller/order/?$type=$query');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders.clear();
        sellerOrders = (ords).map((data) => OrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getSellerOrdersByDateRanged(String startDate, String endDate) async {
    try {
      final r =
          await api(Api.get, 'seller/order/?start=$startDate&end=$endDate,');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders.clear();
        sellerOrders = (ords).map((data) => OrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getSellerOrdersByDateSingle(String date) async {
    try {
      final r = await api(Api.get, 'seller/order/?start=$date');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders.clear();
        sellerOrders = (ords).map((data) => OrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
      final r = await api(Api.get, 'branch/');
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
    notifyListeners();
    await filterOrders();
  }

  OrderProcess process = OrderProcess.all;
  void updateProcess(OrderProcess? value) async {
    if (value == null) return;
    process = value;
    notifyListeners();
    await filterOrders();
  }

  PayType paymentMethod = PayType.unknown;
  void updatePayMethod(PayType? value) async {
    if (value == null) return;
    paymentMethod = value;
    notifyListeners();
    await filterOrders();
  }

  Branch branch = Branch(id: -1, name: 'Салбар сонгох');
  void updateBranch(Branch? value) async {
    if (value == null) return;
    branch = value;
    notifyListeners();
    await filterOrders();
  }

  Supplier supplier = Supplier(id: -1, name: 'Нийлүүлэгч сонгох', stocks: []);
  void updateSupplier(Supplier? value) async {
    if (value == null) return;
    supplier = value;
    notifyListeners();
    await filterOrders();
  }

  Future<dynamic> filterOrders() async {
    await LoadingService.run(
      () async {
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
          if (r == null) return;
          if (r.statusCode == 200) {
            final data = convertData(r);
            List<dynamic> ords = data['orders'];
            orders = (ords).map((data) => OrderModel.fromJson(data)).toList();
            notifyListeners();
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );
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
