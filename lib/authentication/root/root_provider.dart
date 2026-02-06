// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/application.dart';

class RootProvider extends ChangeNotifier {
  AuthState state = AuthState.unknown;
  void updateState(AuthState value) {
    if (state == value) return;
    state = value;
    print(state);
    notifyListeners();
  }

  Future readUser() async {
    print('root initing');
    await Authenticator.initAuthenticator();

    bool splashed = Authenticator.hasSpashed;
    if (!splashed) {
      updateState(AuthState.notSplashed);
      return;
    }

    bool isLoggedIn = await Authenticator.isLoggedIn();
    if (!isLoggedIn) {
      updateState(AuthState.notLoggedIn);
      return;
    }

    final sec = Authenticator.security;
    if (sec == null) {
      updateState(AuthState.notLoggedIn);
      return;
    }

    bool expired = JwtDecoder.isExpired(sec.refresh);
    if (expired) {
      updateState(AuthState.expired);
      return;
    }

    print(sec.role);

    updateState(AuthState.loggedIn);
  }
}
