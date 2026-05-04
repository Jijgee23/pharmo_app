import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

class PharmProvider extends ChangeNotifier {
  List<Customer> filteredCustomers = <Customer>[];
  CustomerDetail customerDetail = CustomerDetail();
  List<Zone> zones = [];
  Zone selectedZone = Zone(id: -1, name: 'Бүс сонгох');
  void reset() {
    filteredCustomers.clear();
    customerDetail = CustomerDetail();
    zones.clear();
    selectedZone = Zone(id: -1, name: 'Бүс сонгох');
    notifyListeners();
  }

  int page = 1;
  int pageSize = 30;
  int totalCount = 0;
  bool hasMore = false;
  bool fetchingMore = false;
  String _filterType = '';
  String _filterValue = '';

  /// Single entry point for both initial load and filtered fetch.
  /// Pass [type]/[value] to filter; omit them to fetch all.
  /// [reset]=true starts from page 1 and clears the list.
  Future fetchCustomers({String? type, String? value, bool reset = true}) async {
    if (fetchingMore) return;
    if (reset) {
      page = 1;
      filteredCustomers.clear();
      hasMore = false;
      _filterType = type ?? '';
      _filterValue = value ?? '';
      notifyListeners();
    }
    fetchingMore = true;
    try {
      final String endpoint;
      if (_filterType.isNotEmpty && _filterValue.isNotEmpty) {
        endpoint =
            'seller/customer/${getEndPoint(_filterType, _filterValue)}&page=$page&page_size=$pageSize';
      } else {
        endpoint = 'seller/customer/?page=$page&page_size=$pageSize';
      }
      final r = await api(Api.get, endpoint);
      if (r == null) return;
      if (apiSucceess(r)) {
        final data = convertData(r) as Map;
        final List results = data['results'] ?? [];
        totalCount = data['count'] ?? 0;
        filteredCustomers.addAll(results.map((p) => Customer.fromJson(p)));
        hasMore = filteredCustomers.length < totalCount;
        if (hasMore) page++;
        notifyListeners();
      } else {
        messageWarning('Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      fetchingMore = false;
      notifyListeners();
    }
  }

  Future fetchMoreCustomers() async {
    if (!hasMore || fetchingMore) return;
    await fetchCustomers(reset: false);
  }

  // Keep old names as thin wrappers so existing callers don't break
  Future getCustomers() => fetchCustomers();
  Future filtCustomers(String type, String v) => fetchCustomers(type: type, value: v);

  Future<Map<String, dynamic>> getCustomerDetail(int custId) async {
    Map<String, dynamic> result = {};
    try {
      final r = await api(Api.get, 'seller/customer/$custId');
      if (r == null) return result;
      if (apiSucceess(r)) {
        dynamic data = convertData(r);
        result = data;
        customerDetail = CustomerDetail.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  sendCustomerLocation(int custId, LatLng position) async {
    try {
      final r = await api(
        Api.patch,
        'seller/customer/$custId/update_location/',
        body: {
          "lat": truncateToSixDigits(position.latitude),
          "lng": truncateToSixDigits(position.longitude)
        },
      );
      if (r == null) return;
      if (apiSucceess(r)) {
        messageComplete('Амжилттай');
        await getCustomerDetail(custId);
      } else {
        messageWarning('Түр хүлээгээд дахин оролдоно уу!');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getEndPoint(String type, String v) {
    if (type == 'name') {
      return '?name__icontains=$v';
    } else if (type == 'phone') {
      return '?phone=$v';
    } else {
      return '?rn=$v';
    }
  }

  editSellerOrder(String note, String pt, int orderId, BuildContext c) async {
    try {
      final u = 'seller/order/$orderId/';
      final b = {"note": note, "payType": pt};
      final r = await api(Api.patch, u, body: b);
      if (r == null) return;
      if (apiSucceess(r)) {
        messageComplete('Амжилттай засагдлаа');
      } else {
        messageWarning('Түр хүлээнэ үү!');
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<OrderModel>? getSellerOrderDetail(int oId) async* {
    OrderModel? result;
    try {
      final u = 'seller/order/$oId/';
      final r = await api(Api.get, u);
      if (r == null) return;
      if (apiSucceess(r)) {
        result = OrderModel.fromJson(convertData(r));
      }
    } catch (e) {
      messageError('Серверийн алдаа');
    }
    yield result!;
  }

  Future changeItemQty(
      {required int oId,
      required int itemId,
      required int qty,
      required BuildContext context}) async {
    try {
      final r = await api(
        Api.patch,
        'seller/order/$oId/update_item/',
        body: {"itemId": itemId, "qty": qty},
      );
      if (r == null) return;
      if (r.statusCode == 200) {
        return buildResponse(1, r, 'Амжилттай өөрлөгдлөө');
      } else if (r.statusCode == 400) {
        if (checker(convertData(r), 'order') == true) {
          return buildResponse(4, null, 'Тухайн захиалгыг засах боломжгүй!');
        } else if (checker(convertData(r), 'itemId') == true) {
          return buildResponse(4, null, 'Бараа олдсонгүй!');
        } else {
          return buildResponse(2, null, 'Алдаа гарлаа');
        }
      } else {
        return buildResponse(2, null, 'Алдаа гарлаа');
      }
    } catch (e) {
      debugPrint(e.toString());
      return buildResponse(2, null, 'Алдаа гарлаа');
    }
  }

  Future registerCustomer(String name, String rn, String email, String phone, String? note,
      String? lat, String? lng, BuildContext context) async {
    try {
      var body = {
        "name": name,
        "rn": rn,
        "email": email,
        "phone": phone,
        note ?? "note": note,
        "lat": lat,
        "lng": lng,
        "zone_id": selectedZone.id
      };
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      if (selectedZone.id == -1) {
        messageWarning('Бүс сонгоно уу!');
      } else {
        var r = await api(Api.post, 'seller/customer/', body: body);
        if (r == null) return;
        if (apiSucceess(r)) {
          messageComplete('Амжилттай бүртгэгдлээ.');
          return;
        }
        final data = convertData(r);
        if (data['error'] == 'name_exists!') {
          messageWarning('Нэр бүртгэлтэй байна!');
        } else {
          messageWarning('Алдаа гарлаа!');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future editCustomer(
      {required int id,
      required String name,
      required String rn,
      required String email,
      required String phone,
      String? phone2,
      String? phone3,
      required String note,
      double? lat,
      double? lng,
      required BuildContext context}) async {
    try {
      var body = {
        "name": name,
        "rn": rn,
        "email": email,
        "phone": phone,
        "phone2": phone2,
        "phone3": phone3,
        "note": note,
        "lat": lat,
        "lng": lng
      };
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      final r = await api(Api.patch, 'seller/customer/$id/', body: body);
      if (r == null) return;
      if (r.statusCode == 200) {
        messageComplete('Амжилттай засагдлаа.');
      } else {
        final data = convertData(r);
        if (data['error'] == 'name_exists!') {
          messageWarning('Нэр бүртгэлтэй байна!');
        } else {
          messageWarning('Алдаа гарлаа!');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setZone(Zone zone) {
    if (selectedZone != zone) {
      selectedZone = zone;
    } else {
      selectedZone = Zone(id: -1, name: 'Бүс сонгох');
    }
    notifyListeners();
  }

  Future getZones() async {
    final url = 'seller/get_delivery_zones/';
    final r = await api(Api.get, url);
    if (r == null) return;
    if (apiSucceess(r)) {
      zones = (convertData(r) as List).map((z) => Zone.fromJson(z)).toList();
      notifyListeners();
    }
  }
}

class CustomerDetail {
  int? id;
  String? name;
  String? rn;
  String? email;
  String? phone;
  String? phone2;
  String? phone3;
  String? note;
  bool? isCmp;
  double? lat;
  double? lng;
  String? created;
  int? addedById;
  bool? loanBlock;
  double? loanLimit;
  bool? loanLimitUse;
  bool? loanBalBlock;
  List<Map<String, dynamic>>? custType;

  CustomerDetail({
    this.id,
    this.name,
    this.rn,
    this.email,
    this.phone,
    this.phone2,
    this.phone3,
    this.note,
    this.isCmp,
    this.lat,
    this.lng,
    this.created,
    this.addedById,
    this.loanBlock,
    this.loanLimit,
    this.loanLimitUse,
    this.loanBalBlock,
    this.custType,
  });

  // Factory method to create a CustomerDetail instance from JSON
  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    return CustomerDetail(
      id: json['id'],
      name: json['name'],
      rn: json['rn'],
      email: json['email'],
      phone: json['phone'],
      phone2: json['phone2'],
      phone3: json['phone3'],
      note: json['note'],
      isCmp: json['is_cmp'],
      lat: json['lat'],
      lng: json['lng'],
      created: json['created'].toString(),
      addedById: json['added_by_id'],
      loanBlock: json['loan_block'],
      loanLimit: parseDouble(json['loan_limit']),
      loanLimitUse: json['loan_limit_use'],
      loanBalBlock: json['loan_bal_block'],
      custType: List<Map<String, dynamic>>.from(json['cust_type']),
    );
  }
}
