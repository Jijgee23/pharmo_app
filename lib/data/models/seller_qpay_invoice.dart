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

  /// The create-order response only carries an invoice when the backend
  /// decided one was needed (a cash-only group) - detect that by presence
  /// of these keys rather than assuming every seller/order/ response has one.
  static bool presentIn(Map<String, dynamic> json) =>
      json['invoiceId'] != null && json['qrTxt'] != null;
}
