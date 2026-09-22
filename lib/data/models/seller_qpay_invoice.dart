import 'package:pharmo_app/application/function/utilities/a_utils.dart';
import 'package:pharmo_app/data/models/order_qrcode.dart';

/// QPay invoice shape returned by the seller-order endpoints
/// (`seller/order/`'s auto-attached invoice, and
/// `seller/order/{orderId}/qpay/`) — distinct from [OrderQRCode], which is
/// shaped for the pharmacist `ci/` flow (invId, totalPrice, totalCount).
class SellerQpayInvoice {
  final String invoiceId;
  final String qrTxt;
  final String? shortUrl;
  final List<BankUrl> urls;

  const SellerQpayInvoice({
    required this.invoiceId,
    required this.qrTxt,
    this.shortUrl,
    required this.urls,
  });

  factory SellerQpayInvoice.fromJson(Map<String, dynamic> json) {
    return SellerQpayInvoice(
      invoiceId: json['invoiceId']?.toString() ?? '',
      qrTxt: json['qrTxt']?.toString() ?? '',
      shortUrl: json['shortUrl']?.toString(),
      urls: json['urls'] != null
          ? (json['urls'] as List).map((url) => BankUrl.fromJson(url)).toList()
          : [],
    );
  }
}

/// One entry of `seller/order/`'s response `orders` list. A single POST can
/// create more than one actual order (e.g. a `split_group`) - each entry
/// carries its own id, its own `requires_payment` flag, and, only when that
/// flag is true, its own nested `qpay` invoice object.
class SellerSubOrder {
  final int id;
  final String orderNo;
  final double totalPrice;
  final double totalCount;
  final bool requiresPayment;
  final SellerQpayInvoice? qpay;

  const SellerSubOrder({
    required this.id,
    required this.orderNo,
    required this.totalPrice,
    required this.totalCount,
    required this.requiresPayment,
    this.qpay,
  });

  factory SellerSubOrder.fromJson(Map<String, dynamic> json) {
    return SellerSubOrder(
      id: parseInt(json['id']),
      orderNo: json['orderNo']?.toString() ?? '',
      totalPrice: parseDouble(json['totalPrice']),
      totalCount: parseDouble(json['totalCount']),
      requiresPayment: json['requires_payment'] == true,
      qpay: json['qpay'] != null
          ? SellerQpayInvoice.fromJson(json['qpay'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Parses the top-level `seller/order/` response's `orders` list.
  static List<SellerSubOrder> listFrom(Map<String, dynamic> res) {
    final list = res['orders'];
    if (list is! List) return [];
    return list.map((e) => SellerSubOrder.fromJson(e as Map<String, dynamic>)).toList();
  }
}
