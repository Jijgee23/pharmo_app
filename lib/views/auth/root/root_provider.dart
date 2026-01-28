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

    // bool expired = JwtDecoder.isExpired(sec.refresh);
    // if (expired) {
    //   updateState(AuthState.expired);
    //   return;
    // }

    updateState(AuthState.loggedIn);
  }
}
