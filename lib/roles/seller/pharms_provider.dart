import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/customer_listing.dart';

class PharmProvider extends ChangeNotifier {
  CustomerDetail customerDetail = CustomerDetail();
  List<Zone> zones = [];
  Zone selectedZone = Zone(id: -1, name: 'Бүс сонгох');
  void reset() {
    customers.reset();
    pickerCustomers.reset();
    customerDetail = CustomerDetail();
    zones.clear();
    selectedZone = Zone(id: -1, name: 'Бүс сонгох');
    notifyListeners();
  }

  /// The customers tab's list. It lives here, not in the tab, so its
  /// search, pages and scroll position survive switching tabs.
  late final customers = CustomerListing(notifyListeners);

  /// The order sheet's customer picker, separate from [customers] so that
  /// picking a customer doesn't disturb the tab.
  late final pickerCustomers = CustomerListing(notifyListeners);

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

  /// POST seller/customer/. The API requires name, rn, phone and the
  /// location, which is taken from the device here.
  Future<bool> registerCustomer({
    required String name,
    required String rn,
    required String phone,
    String? email,
    String? note,
    required BuildContext context,
  }) async {
    if (selectedZone.id == -1) {
      messageWarning('Бүс сонгоно уу!');
      return false;
    }
    try {
      final home = Provider.of<HomeProvider>(context, listen: false);
      // Read only after it resolves, so a first registration sends the
      // actual coordinates rather than none.
      await home.getPosition();
      final body = {
        'name': name,
        'rn': rn,
        'phone': phone,
        'email': _orNull(email),
        'note': _orNull(note),
        'lat': home.currentLatitude,
        'lng': home.currentLongitude,
        'zone_id': selectedZone.id,
      };
      final r = await api(Api.post, 'seller/customer/', body: body);
      if (r == null) return false;
      if (apiSucceess(r)) {
        messageComplete('Амжилттай бүртгэгдлээ.');
        return true;
      }
      _saveFailed(apiBody(r));
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  /// PATCH seller/customer/{id}/ with the editable details. Location and
  /// zone aren't sent, so an edit leaves them as they are; an emptied
  /// optional field is cleared.
  Future<bool> editCustomer({
    required int id,
    required String name,
    required String rn,
    required String phone,
    String? email,
    String? phone2,
    String? phone3,
    String? note,
  }) async {
    try {
      final body = {
        'name': name,
        'rn': rn,
        'phone': phone,
        'email': _orNull(email),
        'phone2': _orNull(phone2),
        'phone3': _orNull(phone3),
        'note': _orNull(note),
      };
      final r = await api(Api.patch, 'seller/customer/$id/', body: body);
      if (r == null) return false;
      if (r.statusCode == 200) {
        messageComplete('Амжилттай засагдлаа.');
        // The lists show the new details at once, without reloading (and
        // losing their place).
        for (final listing in [customers, pickerCustomers]) {
          for (final c in listing.items.where((c) => c.id == id)) {
            c
              ..name = name
              ..rn = rn
              ..phone = phone
              ..phone2 = _orNull(phone2)
              ..phone3 = _orNull(phone3)
              ..note = _orNull(note);
          }
        }
        notifyListeners();
        return true;
      }
      _saveFailed(apiBody(r));
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  static String? _orNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  // [data] is the error response's body.
  void _saveFailed(dynamic data) {
    if ('$data'.contains('name_exists')) {
      messageWarning('Нэр бүртгэлтэй байна!');
    } else {
      messageWarning(apiErrorMessage(data) ?? 'Алдаа гарлаа!');
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
