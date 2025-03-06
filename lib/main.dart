import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/controllers/report_provider.dart';
import 'package:pharmo_app/utilities/global_key.dart';
import 'package:pharmo_app/theme/dark_theme.dart';
import 'package:pharmo_app/theme/light_theme.dart';
import 'package:pharmo_app/utilities/firebase_api.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApi.initFirebase();
  await Upgrader.clearSavedSettings();
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BasketProvider()),
        ChangeNotifierProvider(create: (_) => JaggerProvider()),
        ChangeNotifierProvider(create: (_) => MyOrderProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PharmProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => GetMaterialApp(
        title: 'Pharmo app',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        navigatorKey: GlobalKeys.navigatorKey,
        themeMode: home.themeMode,
        home: UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          showIgnore: false,
          showLater: false,
          showReleaseNotes: false,
          child: const SplashScreen(),
        ),
      ),
    );
  }
}
