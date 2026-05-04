import 'package:http/http.dart' as http;
import 'package:pharmo_app/application/application.dart';

/// http.BaseClient-г extend хийсэн token interceptor.
/// Автоматаар Authorization header нэмж,
/// 401 ирвэл refresh хийж, retry хийнэ.
class AuthClient extends http.BaseClient {
  final http.Client _inner;

  AuthClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final attached = await _attachToken(request);
    if (!attached) {
      return http.StreamedResponse(Stream.value(const []), 401);
    }

    final response = await _inner.send(request);

    if (response.statusCode != 401) return response;

    // 401 — body уншиж code шалгана
    final bytes = await response.stream.toBytes();
    final body = utf8.decode(bytes);
    final Map<String, dynamic> data = jsonDecode(body);
    final code = data['code'];

    if (code == 'token_not_valid') {
      final refreshed = await ApiService.successRefresh();
      if (refreshed) {
        // Retry — шинэ token-оор дахин илгээнэ
        final retryRequest = _copyRequest(request);
        await _attachToken(retryRequest);
        return _inner.send(retryRequest);
      }
      Authenticator.security = null;
      LoadingService.hide();
      await showLogoutDialog(
        Get.context!,
        'Хэрэглэгчийн хандах эрх дууссан байна! \n Нэвтэрнэ үү!',
      );
    }

    if (code == 'authentication_failed') {
      Authenticator.security = null;
      LoadingService.hide();
      await showLogoutDialog(
        Get.context!,
        'Өөр төхөөрөмжөөс нэвтэрсэн байна! \n Нэвтэрнэ үү!',
      );
    }

    // Анхны response-г stream болгон буцаана
    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
    );
  }

  Future<bool> _attachToken(http.BaseRequest request) async {
    await Authenticator.initAuthenticator();
    final security = Authenticator.security;
    if (security == null) return false;
    request.headers['Authorization'] = 'Bearer ${security.access}';
    return true;
  }

  /// BaseRequest copy — retry хийхэд шаардлагатай
  http.BaseRequest _copyRequest(http.BaseRequest original) {
    http.BaseRequest copy;
    if (original is http.Request) {
      copy = http.Request(original.method, original.url)
        ..encoding = original.encoding
        ..bodyBytes = original.bodyBytes;
    } else if (original is http.MultipartRequest) {
      final multi = http.MultipartRequest(original.method, original.url);
      multi.fields.addAll(original.fields);
      multi.files.addAll(original.files);
      copy = multi;
    } else {
      copy = http.Request(original.method, original.url);
      debugPrint('AuthClient: unsupported request type for retry');
    }

    copy.headers.addAll(original.headers);
    return copy;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
