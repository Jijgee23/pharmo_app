import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/application.dart';

class RootProvider extends ChangeNotifier {
  AuthState state = AuthState.unknown;
  void updateState(AuthState value) {
    if (state == value) return;
    state = value;
    notifyListeners();
  }

  Future readUser() async {
    print('root initing');
    await LocalBase.initLocalBase();

    bool splashed = LocalBase.hasSpashed;
    if (!splashed) {
      updateState(AuthState.notSplashed);
      return;
    }

    bool isLoggedIn = await LocalBase.isLoggedIn();
    if (!isLoggedIn) {
      updateState(AuthState.notLoggedIn);
      return;
    }

    final sec = LocalBase.security;
    if (sec == null) {
      updateState(AuthState.notLoggedIn);
      return;
    }

    bool accessExpired = JwtDecoder.isExpired(sec.access);
    if (!accessExpired) {
      updateState(AuthState.loggedIn);
      return;
    }

    if (accessExpired) {
      bool refreshExpired = JwtDecoder.isExpired(sec.refresh);
      if (refreshExpired) {
        updateState(AuthState.expired);
        return;
      }
      var successRefreshed = await refreshed();
      if (successRefreshed) {
        updateState(AuthState.loggedIn);
        return;
      }
      updateState(AuthState.expired);
    }
  }
}
