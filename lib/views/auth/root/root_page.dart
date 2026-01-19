import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/application/utilities/api.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/rep_man/index.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';

enum AuthState { unknown, loggedIn, notLoggedIn, expired }

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthState state = AuthState.unknown;

  void updateState(AuthState value) {
    if (!mounted || state == value) return;
    setState(() {
      state = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchUser();
    });
  }

  Future fetchUser() async {
    await LocalBase.initLocalBase();
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
      var r = await refreshed();
      if (r) {
        updateState(AuthState.loggedIn);
        return;
      } else {
        updateState(AuthState.expired);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = LocalBase.security;
    if (state == AuthState.unknown) {
      return PharmoIndicator(withMaterial: true);
    }
    if (state == AuthState.notLoggedIn || state == AuthState.expired) {
      return LoginPage();
    }
    if (security == null) return LoginPage();

    if (security.role == 'D') {
      return IndexDeliveryMan();
    }
    if (security.role == "R") {
      return IndexRep();
    }
    return IndexPharma();
  }
}
