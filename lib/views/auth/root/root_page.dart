import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/auth/root/root_provider.dart';
import 'package:pharmo_app/views/auth/root/splash_screen.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/rep_man/index.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await readUser(),
    );
  }

  Future readUser() async {
    final rooter = context.read<RootProvider>();
    await rooter.readUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RootProvider>(builder: (context, rooter, child) {
      AuthState state = rooter.state;
      if (state == AuthState.notSplashed) {
        return SplashScreen();
      }
      if (state == AuthState.unknown) {
        return PharmoIndicator(withMaterial: true);
      }
      if (state == AuthState.notLoggedIn || state == AuthState.expired) {
        return LoginPage();
      }
      final security = LocalBase.security;
      if (security == null) return LoginPage();

      if (security.role == 'D') {
        return IndexDeliveryMan();
      }
      if (security.role == "R") {
        return IndexRep();
      }
      return IndexPharma();
    });
  }
}
