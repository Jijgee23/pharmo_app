import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class CompleteRegistration extends StatefulWidget {
  const CompleteRegistration({super.key});

  @override
  State<CompleteRegistration> createState() => _CompleteRegistrationState();
}

class _CompleteRegistrationState extends State<CompleteRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Бүртгэл гүйцээх',style: TextStyle(
          color: Colors.black,
        ),)
      ),
    );
  }
}