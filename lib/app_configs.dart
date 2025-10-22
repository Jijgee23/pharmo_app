import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/auth/root_page.dart';
import 'package:pharmo_app/views/auth/sign_up.dart';
import 'package:pharmo_app/views/cart/cart.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/seller/seller_tracking.dart';
import 'package:provider/single_child_widget.dart';

import 'controllers/a_controlller.dart';

class AppConfigs {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => BasketProvider()),
    ChangeNotifierProvider(create: (_) => JaggerProvider()..tracking()),
    ChangeNotifierProvider(create: (_) => MyOrderProvider()),
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    ChangeNotifierProvider(create: (_) => PharmProvider()),
    ChangeNotifierProvider(create: (_) => IncomeProvider()),
    ChangeNotifierProvider(create: (_) => PromotionProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
    ChangeNotifierProvider(create: (_) => RepProvider()..initTracking()),
    ChangeNotifierProvider(create: (_) => LogProvider())
  ];

  static Map<String, Widget Function(BuildContext)> appRoutes = {
    "/root": (_) => RootPage(),
    "/login": (_) => LoginPage(),
    "/signup": (_) => SignUp(),
    "/reset_password": (_) => ResetPassword(),
    "/complete_registration": (_) => CompleteRegistration(ema: '', pass: ''),
    "/index_pharmo": (_) => IndexPharma(),
    "/index_delivery": (_) => IndexDeliveryMan(),
    "/cart": (_) => Cart(),
    "/seller_track": (_) => SellerTracking(),
  };
}

Future<T?> goNamed<T>(String route, {dynamic arguments}) async {
  final result = await Get.toNamed<T?>("/$route", arguments: arguments);
  return result as T;
}

Future goNamedOfAll<T>(String route, {dynamic arguments}) async {
  await Get.offAndToNamed("/$route", arguments: arguments);
}
