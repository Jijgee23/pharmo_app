import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/auth/root/root_page.dart';
import 'package:pharmo_app/views/auth/root/root_provider.dart';
import 'package:pharmo_app/views/auth/sign_up.dart';
import 'package:pharmo_app/views/SELLER/customer/choose_customer.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/DRIVER/index_driver.dart';
import 'package:provider/single_child_widget.dart';

class AppConfigs {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => RootProvider()),
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => BasketProvider()),
    ChangeNotifierProvider(create: (_) => JaggerProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => MyOrderProvider()),
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    ChangeNotifierProvider(create: (_) => PharmProvider()),
    ChangeNotifierProvider(create: (_) => PromotionProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
    ChangeNotifierProvider(create: (_) => RepProvider()),
    ChangeNotifierProvider(create: (_) => LogProvider()),
    ChangeNotifierProvider(create: (_) => DriverProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ];

  static Map<String, Widget Function(BuildContext)> appRoutes = {
    "/root": (_) => RootPage(),
    "/login": (_) => LoginPage(),
    "/signup": (_) => SignUp(),
    "/reset_password": (_) => ResetPassword(),
    "/complete_registration": (_) => CompleteRegistration(ema: '', pass: ''),
    "/index_pharmo": (_) => IndexPharma(),
    "/index_delivery": (_) => IndexDriver(),
    "/cart": (_) => Cart(),
    "/chooseCustomer": (_) => ChooseCustomer(),
  };
}

Future<T?> goNamed<T>(String route, {dynamic arguments}) async {
  final result = await Get.toNamed<T?>("/$route", arguments: arguments);
  return result as T;
}

Future goNamedOfAll<T>(String route, {dynamic arguments}) async {
  await Get.offAndToNamed("/$route", arguments: arguments);
}
