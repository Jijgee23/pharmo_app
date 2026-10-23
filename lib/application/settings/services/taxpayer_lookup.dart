import 'package:dio/dio.dart';

/// A taxpayer found in e-barimt's public register.
class Taxpayer {
  /// ТТД, the taxpayer identification number.
  final String tin;
  final String name;

  const Taxpayer({required this.tin, required this.name});
}

/// Looks a register number up in e-barimt (api.ebarimt.mn), the same two
/// calls the MACS app uses to fill in a new customer: the register number
/// gives the TIN (getTinInfo), the TIN gives the name (getInfo).
class TaxpayerLookup {
  static const _base = 'https://api.ebarimt.mn/api/info/check';

  // Its own client: nothing of Pharmo's (base URL, client key, token) goes
  // to the tax authority.
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// An organisation's 7 digits, or a citizen's 2 Cyrillic letters + 8 digits.
  static bool isRegister(String value) =>
      RegExp(r'^(\d{7}|[А-ЯЁӨҮ]{2}\d{8})$').hasMatch(normalize(value));

  /// Trimmed and upper-cased, the way the register writes it.
  static String normalize(String value) => value.trim().toUpperCase();

  /// The taxpayer registered under [register], or null if there is none.
  /// Throws a [DioException] when e-barimt can't be reached.
  static Future<Taxpayer?> byRegister(String register) async {
    // An unknown number answers 200 with `"data": null`.
    final tin = await _data('getTinInfo', {'regNo': normalize(register)});
    if (tin == null || '$tin'.isEmpty) return null;
    final info = await _data('getInfo', {'tin': '$tin'});
    final name = info is Map ? '${info['name'] ?? ''}'.trim() : '';
    if (name.isEmpty) return null;
    return Taxpayer(tin: '$tin', name: name);
  }

  static Future<dynamic> _data(String path, Map<String, String> query) async {
    final r = await _dio.get('$_base/$path', queryParameters: query);
    final body = r.data;
    return body is Map ? body['data'] : null;
  }
}
