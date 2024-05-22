import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/screens/auth/login_page.dart';
import 'package:pharmo_app/utilities/firebase_api.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDeLPH1bXffKSXckF-RShuZgIfP023TEps",
        appId: "1:757366069753:android:fda14c67afe6ef7c068528",
        messagingSenderId: "757366069753",
        projectId: "android-pharmo",
        storageBucket: 'android-pharmo.appspot.com',
      ),
    );
  }
  await FirebaseApi.initNotification();
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pharmo app',
      debugShowCheckedModeBanner: false,
      home:  LoginPage(),
    );
  }
}

