import 'package:dio/dio.dart';
import 'package:pharmo_app/application/application.dart' hide Response;

/// Dio interceptor replacing the old http.BaseClient-based AuthClient.
///
/// ApiService's Dio instances use `validateStatus: (_) => true`, so a 401
/// resolves normally instead of throwing a DioException - that's why this
/// handles 401 in onResponse rather than onError. On `token_not_valid` it
/// refreshes the token and retries the request exactly once *through
/// ApiService.plainDio* (no interceptor attached), not through this same
/// Dio instance - retrying through `dio.fetch(...)` would re-enter this
/// onResponse handler and, if the retry also came back 401, recurse
/// forever. On `authentication_failed` it forces a logout, matching the
/// previous implementation.
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    await Authenticator.initAuthenticator();
    final security = Authenticator.security;
    if (security != null) {
      options.headers['Authorization'] = 'Bearer ${security.access}';
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode != 401) {
      return handler.next(response);
    }

    final data = response.data;
    final code = data is Map ? data['code'] : null;

    if (code == 'token_not_valid') {
      final didRefresh = await ApiService.successRefresh();
      if (didRefresh) {
        final security = Authenticator.security;
        final retryOptions = response.requestOptions;
        if (security != null) {
          retryOptions.headers['Authorization'] = 'Bearer ${security.access}';
        }
        try {
          final retryResponse = await ApiService.plainDio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Fall through and hand back the original 401 below.
        }
      } else {
        Authenticator.security = null;
        LoadingService.hide();
        await showLogoutDialog(
          Get.context!,
          'Хэрэглэгчийн хандах эрх дууссан байна! \n Нэвтэрнэ үү!',
        );
      }
    }

    if (code == 'authentication_failed') {
      Authenticator.security = null;
      LoadingService.hide();
      await showLogoutDialog(
        Get.context!,
        'Өөр төхөөрөмжөөс нэвтэрсэн байна! \n Нэвтэрнэ үү!',
      );
    }

    handler.next(response);
  }
}
