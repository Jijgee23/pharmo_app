import 'package:pharmo_app/application/function/utilities/a_utils.dart';

/// GET seller/payment_settings/ — the caller's own supplier's payment
/// setup: whether QPay is configured, the bank accounts to read out to a
/// customer paying by transfer, whether the supplier still offers
/// "Дансаар", and the free-delivery threshold.
class SellerPaymentSettings {
  final int supplierId;
  final String supplierName;
  final double delvLimit;
  final List<BankAccount> bankAccounts;
  final bool hasQpay;
  final bool canPayByTransfer;

  const SellerPaymentSettings({
    required this.supplierId,
    required this.supplierName,
    required this.delvLimit,
    required this.bankAccounts,
    required this.hasQpay,
    required this.canPayByTransfer,
  });

  factory SellerPaymentSettings.fromJson(Map<String, dynamic> json) {
    return SellerPaymentSettings(
      supplierId: parseInt(json['supplier_id']),
      supplierName: json['supplier_name']?.toString() ?? '',
      delvLimit: parseDouble(json['delv_limit']),
      bankAccounts: json['bank_accounts'] != null
          ? (json['bank_accounts'] as List).map((e) => BankAccount.fromJson(e)).toList()
          : [],
      hasQpay: json['has_qpay'] == true,
      canPayByTransfer: json['can_pay_by_transfer'] == true,
    );
  }
}

class BankAccount {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String? note;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.note,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: parseInt(json['id']),
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountHolder: json['account_holder']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }
}
