import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/models/a_models.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/main/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  LoadState loadState = LoadState.loading;
  void updateLoadState(LoadState state) {
    setState(() {
      loadState = state;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    updateLoadState(LoadState.loading);
    await LocalBase.initLocalBase();
    await Future.delayed(Duration(seconds: 1)).then(
      (value) => updateLoadState(LoadState.loaded),
    );
  }

  @override
  Widget build(BuildContext context) {
    Security? security = LocalBase.security;
    if (loadState == LoadState.loading) {
      return PharmoIndicator(withMaterial: true);
    }
    if (LocalBase.security == null) {
      return LoginPage();
    } else {
      if (JwtDecoder.isExpired(security!.access) ||
          JwtDecoder.isExpired(security.refresh)) {
        return LoginPage();
      } else {
        if (security.role == 'D') {
          return IndexDeliveryMan();
        }
        return IndexPharma();
      }
    }
    // if (authState == AuthState.noDetermined) {
    //   return Material(
    //     child: Center(
    //       child: PharmoIndicator(),
    //     ),
    //   );
    // }
    // return LoginPage();
  }
}
