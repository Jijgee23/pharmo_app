import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/auth/login_page.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(const MyApp());
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => BasketProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
