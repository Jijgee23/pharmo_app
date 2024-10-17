import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';

class CreatePassword extends StatefulWidget {
  final String email;
  const CreatePassword({super.key, required this.email});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final TextEditingController email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SideMenuAppbar(title: 'Нууц үг үүсгэх'),
      body: Container(),
    );
  }
}
